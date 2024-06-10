class_name Player 
extends CharacterBody2D

@export_category("Movement")
@export var speed: float = 3
@export_category("Sword")
@export var sword_damage: int = 2

#Vida do jogador
@export_category("Life")
@export var max_health: int = 311
@export var health: float = max_health
@export var death_prefab: PackedScene

@export_category("Ritual")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30
@export var ritual_scene: PackedScene

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var damage_digit_marker = $DamageDigitMarker


var input_vector: Vector2 = Vector2(0,0)

#Propriedades de movimento
var is_running: bool = false
var was_running: bool = false

#Propriedade de ataque
var is_attacking: bool = false

#Temporizadores
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0

#Propriedades do ataque inimigo
var enemy: Enemy
var is_attacking_enemies: bool = false
var damage_to_player: int

var die_player = false
var regenerete_digit_prefab: PackedScene

signal meat_collected(value: int)
signal life_changed(player_hearts, type)

func _ready():
	GameManager.player = self
	regenerete_digit_prefab = preload("res://misc/LifeRegenerete.tscn")
	
func _process(delta: float) -> void:
	#Injetando a posição do player no Game_Manger
	GameManager.player_position = position
	
	#Ler inputs
	read_input()
	
	#AProcessar ataque
	update_attack_cooldown(delta)
	if Input.is_action_just_pressed('attack'):
		if Input.is_action_pressed("move_down"):
			attack("attack_down_")
		elif Input.is_action_pressed("move_up"):
			attack("attack_up_")
		else:
			attack("attack_side_")
	#Processar animação
	play_run_idle_animation()

	#Processo de rotação de sprite
	if not is_attacking:
		rotate_sprite()
		
	#Processar ritual
	#update_ritual(delta)
	
	#Processa ataque do inimigo
	update_hitbox_detection(delta)

func update_ritual(delta: float) -> void:
	ritual_cooldown -= delta
	if ritual_cooldown > 0: return
	ritual_cooldown = ritual_interval
	
	#criar o ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)
	
func _physics_process(delta: float) -> void:
	#Modificar a velocidade
	var target_velocity = input_vector * speed * 100.0
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.09)
	move_and_slide()
		
func read_input() -> void:
	position.x = clamp(position.x, -320, 1425)
	position.y = clamp(position.y, -290, 950) #2520
	
	#Obter o input vector
	input_vector = Input.get_vector('move_left','move_right', 'move_up', 'move_down', 0.15)
	
	#Apagar deadzone do input vector
	var deadzone = 0.15
	if abs(input_vector.x) < 0.15:
		input_vector.x = 0.0
	if abs(input_vector.y) < 0.15:
		input_vector.y = 0.0
		
	#Atualizar o is_running
	was_running = is_running
	is_running = not input_vector.is_zero_approx()
		
func play_run_idle_animation() -> void:
	#Tocar animação
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play('run')
			else:
				animation_player.play('idle')
		
func rotate_sprite() -> void:
	#Girar sprite
	if input_vector.x > 0:
		#desmarcar flip_h do Sprite2D
		sprite.flip_h = false
	elif input_vector.x < 0:
		#marcar flip_h do Sprite2D
		sprite.flip_h = true
		
# Ataque do player
func attack(animation) -> void:
	if is_attacking:
		return
	#Roda a animação de ataque
	animation_player.play(animation + str(randi_range(1,2)))
	# Configurar temporizador
	attack_cooldown = 0.6
	#Marca ataque
	is_attacking = true

func update_attack_cooldown(delta) -> void:
	#Atualizar temporizador do ataque
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play('idle')

func deal_damage_to_enemies() -> void:
	#Verifica o que tem dentro da aréa de ataque
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		#Verifica se o que tem é inimigo
		if body.is_in_group('enemies'):
			
			#Seleciona o inimigo
			var enemy: Enemy = body
			
			print("Inimigo entrou na aréa de ataque!")
			
			#Pegando a posição do inimigo
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction = Vector2.ZERO
			
			#Verificando para qual direção o inimigo esta
			#e atribuindo isso a direção de ataque
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			
			#Verificando se durante o ataque o player
			#esta virado para cima ou para baixo
			if input_vector.y == -1:
				attack_direction = Vector2.UP
			elif input_vector.y == 1:
				attack_direction = Vector2.DOWN
			print(attack_direction)
			
			#Retornando a posição do inimigo em relaçao ao ataque
			var dot_product = direction_to_enemy.dot(attack_direction)
			
			print(dot_product)
			
			#Verificando se o inimigo esta dentro da
			#zona de ataque, se sim ele ataca.
			if dot_product >= 0.7:
				enemy.damage(sword_damage)
# ---------------- ATAQUE FIM ----------------------------------------------

#Atualiza o temporizador e a frequencia de ataque inimigo
func update_hitbox_detection(delta: float) -> void:
	if is_attacking_enemies: return
	
	#Temporizador  
	hitbox_cooldown -= delta
	
	#Verifica se o ataque já foi realizado.
	if hitbox_cooldown > 0: 
		return
	
	var areas = hitbox_area.get_overlapping_areas()
	for area in areas:
		if area.get_parent().is_in_group("enemies"):
			if area.name == 'AtackArea':
				enemy = area.get_parent()
				if not enemy.is_attacking and not die_player:
					#Frequencia de golpes do inimigo
					hitbox_cooldown = enemy.frequency_hitbox
					
					#Atribui animação ao inimigo
					enemy.animation_enemy.play('enemy_attack')
					
					enemy.player = self
					enemy.is_attacking = true;

func _on_HitBoxArea_body(body):
	if body == self:
		print("Player saiu da aréa de ataque!")

#Função para definir dano ao jogador
func damage(amount: int) -> void:

	#Verifica se o play já morreu
	#para evitar que essa função seja chamada
	#mesmo apos o jogador morto
	if health <= 0: return
	
	#Diminuindo a vida do jogador 
	health -= amount
	
	life_changed.emit(amount, "damage")
	
	print("Jogador recebeu ",amount," de dano e ficou com ",health," de vida")
	
	#Pisca o jogador ao tomar dano
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(tween.EASE_IN)
	tween.set_trans(tween.TRANS_QUINT)
	tween.tween_property(self, "modulate",Color.WHITE, 0.3)
	
	#Processar morte
	if health <= 0:
		die()

func die() -> void:
	#verifica se existe uma cena de morte carregada
	if death_prefab:
		var death_object = death_prefab.instantiate()
		#Pega aonde o jogador morreu e substitue pela cena de morte
		death_object.position = position
		get_parent().add_child(death_object)
	#Faz toda a instancia do jogador desaparecer
	
	print("Player morreu!")
	die_player = true
	queue_free()

func heal(amount: int) -> int:
	health += amount
	if health > max_health:
		health = max_health
		
	regere_health(amount)
	
	life_changed.emit(amount, 'regenerete')
	print("Player recebeu cura de ",amount," e ficou com ",health,"/",max_health," de vida")
	return health
	
func regere_health(input):
	var regenerete_health = regenerete_digit_prefab.instantiate()
	regenerete_health.value = input
	
	print(regenerete_health.value)
	
	if damage_digit_marker:
		regenerete_health.global_position = damage_digit_marker.global_position
	else:
		regenerete_health.global_position = global_position
	get_parent().add_child(regenerete_health)
