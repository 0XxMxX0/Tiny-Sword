extends Node2D

var regeneration_amount: int

func _ready() -> void:
	$Area2D.area_entered.connect(on_body_entered)

func on_body_entered(Area: Area2D) -> void:
	if Area.name == 'HitboxArea':
		var area = Area.get_parent()
		if area.is_in_group('Player') or area.is_in_group('Player2'):
			var player = area
			regeneration_amount = randi_range(0, 30)
			if player.health < player.max_health:
				player.heal(regeneration_amount)
				queue_free()
			else:
				player.regere_health("Vida cheia!")
			
