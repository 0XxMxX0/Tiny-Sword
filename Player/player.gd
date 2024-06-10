class_name Player 
extends CharacterBody2D

@export_category("Movement")
@export var speed: float = 3
var input_vector: Vector2 = Vector2(0,0)

@export_category("Sword")
@export var sword_damage: int = 2

#Vida do jogador
@export_category("Life")
@export var max_health: int = 311
@export var health: float = max_health
var die_player = false


#Carregar sprite do Player 
@onready var sprite: Sprite2D = $Sprite2D

#Carregar animação do player
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var death_prefab: PackedScene

@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var info_digit_marker = $InfoDigitMarker

#Propriedades de movimento
var is_running: bool = false
var was_running: bool = false

#Propriedade de ataque
var is_attacking: bool = false
var attack_cooldown: float = 0.0

#Propriedades do ataque inimigo
var enemy: Enemy
var is_attacking_enemies: bool = false
var hitbox_cooldown: float = 0.0

#Animação do numero ao pegar uma carne
var info_digit_prefab: PackedScene

#Sons do player
@onready var running_player = $running_player


#Sinais
signal meat_collected(value: int)
signal life_changed(player_hearts, type)

func _ready():
	GameManager.player = self
	info_digit_prefab = preload("res://effects/info_digit/info_digital.tscn")
	meat_collected.connect(func(): GameManager.meat_count += 1)
	
func _process(delta: float) -> void:
	#Injetando a posição do player no Game_Manger
	GameManager.player_position = position
	
	#Ler inputs
	read_input()
	
	#Processar animação
	play_run_idle_animation()

	#Processo de rotação de sprite
	if not is_attacking:
		rotate_sprite()
	
	#Processa ataque do inimigo
	update_hitbox_detection(delta)
	
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

#Ataque do inimigo
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
					
					enemy.player = self
					enemy.is_attacking = true;

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

#Função para fazer o jogador morrer
func die() -> void:
	GameManager.end_game()
	
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

#Atribuir vida ao jogador
func heal(amount: int) -> int:
	health += amount
	if health > max_health:
		health = max_health
		
	info(amount)
	
	life_changed.emit(amount, 'regenerete')
	return health

#Função para gerar valores/textos saltando no player
func info(input):
	var info_input = info_digit_prefab.instantiate()
	info_input.value = input
	print(info_input.value)
	if info_digit_marker:
		info_input.global_position = info_digit_marker.global_position
	else:
		info_input.global_position = global_position
		
	get_parent().add_child(info_input)
