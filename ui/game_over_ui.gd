class_name GameOverUi
extends CanvasLayer

@onready var time_label: Label = %TimeLabel
@onready var monsters_label: Label = %MonstersLabel

@onready var restart_delay: float = 5.0
var restart_cooldown: float

# Called when the node enters the scene tree for the first time.
func _ready():
	time_label.text = GameManager.time_elapsed_string
	monsters_label.text = str( GameManager.dead_enemis_total)
	restart_cooldown = restart_delay
	
func _process(delta):
	restart_cooldown -= delta
	if restart_cooldown <= 0.0:
		restart_game()

func restart_game():
	GameManager.reset()
	get_tree().reload_current_scene()
