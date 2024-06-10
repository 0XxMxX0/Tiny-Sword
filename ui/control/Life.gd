extends Control

@onready var hearts_texture = $Hearts
@onready var player: Player = GameManager.player
var heart_size: int

func _ready():
	player.life_changed.connect(on_player_life_changed)

func on_player_life_changed(player_hearts: float, type: String) -> void:
	
	hearts_texture.size.x = player.health + 5
