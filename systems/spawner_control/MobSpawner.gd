class_name MobSpawner
extends Node2D

@export var creatures: Array[PackedScene]
var mobs_per_minute: float = 60.0

@onready var path_follow_2d: PathFollow2D = %PathFollow2D
@onready var path_follow_2d_barrel: PathFollow2D = %PathFollow2D_barrel
var cooldown: float = 0.0
var barril_cooldown: int = 0

func _process(delta: float) -> void:
	if GameManager.is_game_over: return
	#temporizador
	cooldown -= delta
	
	if cooldown > 0: return
	
	#frequencia de spawn por minuto
	#60 monstros/min = 1 montros por segundo
	#120 monstros/min = 2 monstros por segundo
	#intervalo em segundos entre monstros => 60 / frequência
	var interval = 60.0 / mobs_per_minute
	cooldown = interval
	
	#Instanciar uma criatura aleatoria
	# - Pegar criatuara aleatoria
	var index = randi_range(0, creatures.size() - 1)
	var creature_scene = creatures[index]
	var creature = creature_scene.instantiate()
	
	#Definindo probabilidades de aparecer o inimigo
	#de acordo com o nivel atual
	var probability = randi_range(0, 30)
	var nivel: int;
	
	if probability == 3 or probability == 15 or probability == 18:
		nivel = 3
	elif probability >= 4 and probability <= 14:
		nivel = 2
	elif probability == 20 or probability == 1:
		nivel = 4
	else:
		nivel = 1
		
	if creature.nivel != nivel: return
	
	var creature_type: PathFollow2D
	if barril_cooldown == 5: 
		barril_cooldown = 0
		return
	else:
		if creature.type == 'Barel':
			creature_type = path_follow_2d_barrel
			barril_cooldown += 1
		else:
			creature_type = path_follow_2d
	
	# - Pegar um ponto aleatorio
	var point = get_point(creature_type)
	
	# - Colocar na posição certa
	creature.global_position = get_point(creature_type)
	get_parent().add_child(creature)
	
	
func get_point(creature_type) -> Vector2:
	creature_type.progress_ratio = randf() #Random Number
	return creature_type.global_position
