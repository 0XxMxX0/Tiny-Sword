extends Node

@export var speed: float = 1

var enemy: Enemy
var sprite: AnimatedSprite2D

func _ready():
	enemy = get_parent()
	sprite = enemy.get_node('AnimatedSprite2D')

func _physics_process(delta: float) -> void:
	if enemy.is_attacking: return
	
	if GameManager.player == null and GameManager.player2 == null:
		sprite.play('stop')
		return
	
	#Calcula direção
	var player_position = GameManager.player_position
	var player2_position = GameManager.player_position2
	#Diferença de posição
	var difference = player_position - enemy.position
	var difference2 = player2_position - enemy.position
	
	var distance_to_player = difference.length()
	var distance_to_player2 = difference2.length()
	
	var closest_difference = difference
	if distance_to_player2 < distance_to_player:
		closest_difference = difference2
	
	if GameManager.player != null and GameManager.player2 != null:
		if GameManager.player2.die_player and not GameManager.player.die_player:
			closest_difference = difference
		elif not GameManager.player2.die_player and GameManager.player.die_player:
			closest_difference = difference2
			
	elif GameManager.player != null and GameManager.player2 == null:
		closest_difference = difference
	elif GameManager.player == null and GameManager.player2 != null:
		closest_difference = difference2
	
	var input_vector = closest_difference.normalized()
	
	#Movimentação
	enemy.velocity = input_vector * speed * 100.0
	if enemy.type != 'Barel':
		enemy.move_and_slide()
	
	#Girar sprite
	if input_vector.x > 0:
		#desmarcar flip_h do Sprite2D
		sprite.flip_h = false
	elif input_vector.x < 0:
		#marcar flip_h do Sprite2D
		sprite.flip_h = true
		
	#Indicando se o play esta virado para a esquerda ou para a direita
	enemy.flip_h = sprite.flip_h
