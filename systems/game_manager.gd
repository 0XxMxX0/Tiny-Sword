extends Node

signal game_over

@onready var player: Player
@onready var player2: Player2
var player_position: Vector2
var player_position2: Vector2
	
var is_game_over: bool = false

var time_elapsed: float = 0.0
var time_elapsed_string: String
var dead_enemis_total: int = 0

func end_game():
	if is_game_over: return
	is_game_over = true
	game_over.emit()

func reset():
	player = null
	is_game_over = false
	for connection in game_over.get_connections():
		game_over.disconnect(connection.callable)
	time_elapsed = 0.0
	time_elapsed_string  = ''
	dead_enemis_total = 0
		
func _process(delta:float):
	time_elapsed += delta
	var time_elapsed_in_seconds: int = floori(time_elapsed)
	var seconds: int = time_elapsed_in_seconds % 60
	var minutes: int  = time_elapsed_in_seconds / 60
	time_elapsed_string = "%02d:%02d" % [minutes, seconds]
	
