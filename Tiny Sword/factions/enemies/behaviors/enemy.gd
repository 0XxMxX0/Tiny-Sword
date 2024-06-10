class_name Enemy
extends Node2D

#Vida do inimigo
@export_category("Life")
@export var health: int = 10

#Responsavel por carregar a cena da morte
@export var death_prefab: Array[PackedScene]

#Nivel do inimigo
@export var nivel: int = 1

#Responsavel por atribuir o dano inimigo 
@export_category("Attack")
@export var hit_damage: int
@export var frequency_hitbox: float = 0.10

#Verificar em qual direção o inimigo esta apontado
@export_category("Moviment and direction")
@export var flip_h: bool

@export var type: String

@onready var animation_enemy: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_digit_marker = $DamageDigitMarker
@onready var attack_area: Area2D = $AtackArea

var is_attacking: bool = false;
var player
var damage_digit_prefab: PackedScene

func _ready():
	damage_digit_prefab = preload("res://misc/damage_digit.tscn")

func _process(delta):
	#Processar dano e verifica se o inimigo existe
	if is_attacking and player != null:
		if self.animation_enemy.frame == self.animation_enemy.sprite_frames.get_frame_count('enemy_attack') - 1:
			
			if self.type == 'Barel':
				self.damage(self.health)
				var bodies = self.attack_area.get_overlapping_bodies()
				var areas = player.hitbox_area.get_overlapping_areas()
				
				if bodies:
					for body in bodies:
						if body != self:
							body.damage(hit_damage)
				if areas:
					for area in areas:
						if area.get_parent().is_in_group("enemies"):
							if area.name == "AtackArea":
								if self == area.get_parent():
									#Atribui dano ao jogador
									player.damage(hit_damage)
								else:
									is_attacking = false;
									self.animation_enemy.play('default')
			else:
				var areas = player.hitbox_area.get_overlapping_areas()
				for area in areas:
					if area.get_parent().is_in_group("enemies"):
						if area.name == "AtackArea":
							if self == area.get_parent():
								#Atribui dano ao jogador
								player.damage(hit_damage)
							else:
								is_attacking = false;
								self.animation_enemy.play('default')
								
			#Inimigo não esta atacando mais
			is_attacking = false;
			#Animação de correr ao finalizar o ataque
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

