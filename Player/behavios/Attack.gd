extends Node

@onready var player: Player
@onready var attack_sound: AudioStreamPlayer2D = $"../attack_player"

#Temporizadores
var attack_cooldown: float = 0.0

#tipo de ataque
var type_attack: String = ''

func _ready():
	player = get_parent()

func _process(delta) -> void :
	#Processar ataque
	update_attack_cooldown(delta)
	if Input.is_action_just_pressed('attack'):
		if Input.is_action_pressed("move_down"):
			type_attack = 'down'
			attack("attack_down_")
		elif Input.is_action_pressed("move_up"):
			type_attack = 'up'
			attack("attack_up_")
		else:
			type_attack = 'side'
			attack("attack_side_")
	
#Atualizando tempo de ataque
func update_attack_cooldown(delta) -> void:
	#Atualizar temporizador do ataque
	if player.is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			player.is_attacking = false
			player.is_running = false
			player.animation_player.play('idle')

#Iniciando ataque do player
func attack(animation) -> void:
	if player.is_attacking:
		return
	attack_sound.play(0.0)
	#Roda a animação de ataque
	player.animation_player.play(animation + str(randi_range(1,2)))
	
	# Configurar temporizador
	attack_cooldown = 0.6
	
	#Marca ataque
	player.is_attacking = true

#Realizando ataque aos inimigos proximos
func deal_damage_to_enemies() -> void:
	
	#Verifica o que tem dentro da aréa de ataque
	var bodies = player.sword_area.get_overlapping_bodies()
	for body in bodies:
		#Verifica se o que tem é inimigo
		if body.is_in_group('enemies'):
			#Pegando a posição do inimigo
			var direction_to_enemy = (body.position - player.position).normalized()
			
			
			#Verifica para qual lado deve ser atacado o inimigo
			var attack_direction = Vector2.ZERO
			if type_attack == 'side':
				if player.sprite.flip_h:
					attack_direction = Vector2.LEFT
				else:
					attack_direction = Vector2.RIGHT
			else:
				#Verificando se o ataque foi para cima ou para baixo
				if type_attack == 'up':
					attack_direction = Vector2.UP
				elif type_attack == 'down':
					attack_direction = Vector2.DOWN
					
			
			#Retornando a posição do inimigo em relaçao ao ataque
			var dot_product = direction_to_enemy.dot(attack_direction)
			
			#Dinamica de ataque
			var probability = randi_range(0, 20)
			var attack = ""
			if probability == 1 or probability == 5:
				attack = "Ataque critico!"
			elif probability >= 5 and probability <= 7:
				attack = "Ataque leve!"
			elif probability >= 15 and probability <= 17:
				attack = "Errou!"
			
			#Verificando se o inimigo esta dentro da
			#zona de ataque, se sim ele ataca.
			var health_enemy = body.health
			if dot_product >= 0.7:
				if attack == "":
					body.damage(player.sword_damage)
				else:
					if attack == "Ataque critico!":
						body.damage(player.sword_damage + 10)
					elif attack == "Ataque leve!":
						body.damage(player.sword_damage - 8)
					
			if body.health == health_enemy:
				player.info("Errou!")
			else:
				if attack != "":
					player.info(attack)
