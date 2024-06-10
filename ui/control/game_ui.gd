extends CanvasLayer

@onready var timer_label: Label = %TimerLabel
@onready var gold_label: Label = %GoldLabel
@onready var deads_label: Label = %DeadsLabel

func _process(delta:float):
	timer_label.text = GameManager.time_elapsed_string
	
	if GameManager.dead_enemis_total > 0:
		deads_label.text = str(GameManager.dead_enemis_total)
	else:
		deads_label.text = str(0)
