extends CanvasLayer

@onready var timer_label: Label = %TimerLabel
@onready var gold_label: Label = %GoldLabel
@onready var deads_label: Label = %DeadsLabel
var time_elapsed: float = 0.0
var meat_counter: int = 0

func _ready():
	GameManager.player.meat_collected.connect(on_meat_collected)

func _process(delta:float):
	time_elapsed += delta
	var time_elapsed_in_seconds: int = floori(time_elapsed)
	var seconds: int = time_elapsed_in_seconds % 60
	var minutes: int  = time_elapsed_in_seconds / 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
	
	if GameManager.dead_enemis_total > 0:
		deads_label.text = str(GameManager.dead_enemis_total)
	else:
		deads_label.text = str(0)

func on_meat_collected(value: int) -> void:
	meat_counter += 1
	#meat_label.text = value;
