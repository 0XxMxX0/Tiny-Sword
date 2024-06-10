class_name Enemy
extends Node2D

@onready var player: Player

var input_vector

#Vida do inimigo
@export_category("Life")
@export var health: int = 10

#Classe do inimigo
@export var type: String

#Nivel do inimigo
@export var nivel: int = 1

#Responsavel por carregar a cena da morte
@export var death_prefab: Array[PackedScene]

#Responsavel por atribuir o dano inimigo 
@export_category("Attack")
@export var hit_damage: int
@export var frequency_hitbox: float = 0.10
@onready var attack_area: Area2D = $AtackArea

#Aréa de colissão do ataque inimigo
@onready var collision_shape = %CollisionShape2D
@export var collision_shape_right: float
@export var collision_shape_left: float
@export_category("Attack control")
@export var is_attacking: bool = false;

#Verificar em qual direção o inimigo esta apontado
@export_category("Direction")
@export var flip_h: bool

#Animação do inimigo
@onready var animation_enemy: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound_attack = $sound_attack


#Responsavel por atribuir o numero de dano que o inimigo recebe
var damage_digit_prefab: PackedScene
@onready var damage_digit_marker = $DamageDigitMarker

#Sons do inimigo
@onready var attack_sound = $Attack_sound

func _ready():
	damage_digit_prefab = preload("res://effects/damage_digit/damage_digit.tscn")
	player = GameManager.player
	

func _process(delta):
	if not player: return
	#Processar dano e verifica se o player existe
	if is_attacking:
		
		#Atribui animação ao inimigo
		self.animation_enemy.play('enemy_attack')
		
		if self.animation_enemy.frame == self.animation_enemy.sprite_frames.get_frame_count('enemy_attack') - 1:
			if attack_sound:
				attack_sound.play(0.0)
				
			if self.type == 'Barel':
				barel(self)
			
			var areas = player.hitbox_area.get_overlapping_areas()
			for body in areas:
				if body.get_parent().is_in_group("enemies"):
					if body.name == "AtackArea":
						if self == body.get_parent():
							print(self.input_vector)
							#Atribui dano ao jogador
							player.damage(hit_damage)
						else:
							is_attacking = false;
							self.animation_enemy.play('default')
								
			#Inimigo não esta atacando mais
			is_attacking = false;
			#Animação de default ao finalizar o ataque
			self.animation_enemy.play('default')

#Função para definir dano ao Inimigo
func damage(amount: int) -> void:
	#Diminuindo a vida do inimigo 
	health -= amount
	
	print("Inimigo recebeu ",amount," de dano e ficou com ",health," de vida")
	
	#Pisca o inimigo ao tomar dano
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(tween.EASE_IN)
	tween.set_trans(tween.TRANS_QUINT)
	tween.tween_property(self, "modulate",Color.WHITE, 0.3)
	
	#Empurrando o Inimigo pra tras ao tomar dano
	if self.flip_h:
		self.position.x += 20
	else:
		self.position.x -= 20
	
	#criar DamageDigit
	var damage_digit = damage_digit_prefab.instantiate()
	damage_digit.value = amount
	if damage_digit_marker:
		damage_digit.global_position = damage_digit_marker.global_position
	else:
		damage_digit.global_position = global_position
		
	get_parent().add_child(damage_digit)
	
	
	#Processar morte
	if health <= 0:
		die()

func barel(barel) -> void:
	#Barris se explodem e levam todos juntos
	barel.damage(self.health)
	
	var areas = self.attack_area.get_overlapping_areas()
	if areas:
		for area in areas:
			if area.name == 'AtackArea':
				if area.get_parent().type == 'Barel':
					area.get_parent().is_attacking = true 
								
	var bodies = self.attack_area.get_overlapping_bodies()
	if bodies:
		for body in bodies:
			if body != self:
				body.damage(self.hit_damage)
	
	
func die() -> void:
	#verifica se existe uma cena de morte carregada
	#if death_prefab:
	#Pegando index aleatorios do array de spawn de morte
	#do inimigo
	var index =  randi_range(0, death_prefab.size() - 1)
	var death_scene = death_prefab[index]
	var death_object = death_scene.instantiate()
	
	#Pega aonde o inimigo morreu e substitue pela cena de morte
	death_object.position = position
	get_parent().add_child(death_object)
	
	GameManager.dead_enemis_total += 1
	
	#Faz toda a instancia do inimigo desaparecer
	queue_free()
