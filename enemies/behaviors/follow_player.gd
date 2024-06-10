extends Node

@export var speed: float = 1

var enemy: Enemy
var sprite: AnimatedSprite2D

func _ready():
	enemy = get_parent()
	sprite = enemy.get_node('AnimatedSprite2D')

func _physics_process(delta: float) -> void:
	if GameManager.is_game_over: return
	
	#Se o inimigo estiver atacando ele não pode andar
	if enemy.is_attacking: return
	
	#Verificando se o player's estão mortos ou se existem
	if GameManager.player == null and GameManager.player2 == null:
		sprite.play('stop')
		return
	
	#Calcula direção
	var player_position = GameManager.player_position
	
	#Diferença de posição
	var difference = player_position - enemy.position
	var distance_to_player = difference.length()
	
	var closest_difference = difference
	if GameManager.player2 != null:
		#Pegando posição do player2
		var player2_position = GameManager.player_position2
		
		#Diferença de posição em relação ao inimigo
		var difference2 = player2_position - enemy.position
		var distance_to_player2 = difference2.length()
		
		#Verifica qual player esta mais perto
		if distance_to_player2 < distance_to_player:
			closest_difference = difference2
			distance_to_player = distance_to_player2
		
		if GameManager.player != null and GameManager.player2 != null:
			if GameManager.player2.die_player and not GameManager.player.die_player:
				closest_difference = difference
			elif not GameManager.player2.die_player and GameManager.player.die_player:
				closest_difference = difference2
				
		elif GameManager.player != null and GameManager.player2 == null:
			closest_difference = difference
		elif GameManager.player == null and GameManager.player2 != null:
			closest_difference = difference2
			
	#Normaliza a distancia entre o player e o inimigo
	enemy.input_vector = closest_difference.normalized()
	
	#Distancia minima entre um player e os inimigos
	if distance_to_player < 30: return
	
	#Movimentação
	enemy.velocity = enemy.input_vector * speed * 100.0
	if enemy.type != 'Barel':
		enemy.move_and_slide()
	
	#Girar sprite e o CollisionShape da aréa de ataque
	var collision_shape
	if enemy.input_vector.x > 0:
		#desmarcar flip_h do Sprite2D
		sprite.flip_h = false
		collision_shape = enemy.collision_shape_right
	elif enemy.input_vector.x < 0:
		#marcar flip_h do Sprite2D
		sprite.flip_h = true
		collision_shape = enemy.collision_shape_left
	if enemy:
		for child in enemy.attack_area.get_children():
			if child.name == 'CollisionShape2D':
				child.position.x = collision_shape
		
	#Indicando se o inimigo esta virado para a esquerda ou para a direita
	enemy.flip_h = sprite.flip_h
