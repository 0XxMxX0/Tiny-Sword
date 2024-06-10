extends Node2D

var regeneration_amount: int
var amount_cooldown: float = 0.0
var amount_free: bool = false;

#Carregar animação da carne
@onready var animation_meat: AnimatedSprite2D = $"."

func _ready() -> void:
	$Area2D.area_entered.connect(on_body_entered)

func _process(delta):
	#Limitando o tempo de vida da carne
	if not amount_free:
		update_cooldown_meat(delta)
	
	if amount_free:
		animation_meat.play("die")
		
		if animation_meat.frame == animation_meat.sprite_frames.get_frame_count('die') - 1:
			amount_cooldown = 0.0
			amount_free = false
			queue_free()

func update_cooldown_meat(delta):
	if amount_cooldown > 5.0: 
		amount_free = true
		return 
	amount_cooldown += delta

func on_body_entered(Area: Area2D) -> void:
	if Area.name == 'HitboxArea':
		var area = Area.get_parent()
		if area.is_in_group('Player') or area.is_in_group('Player2'):
			var player = area
			regeneration_amount = randi_range(0, 30)
			if player.health < player.max_health:
				player.heal(regeneration_amount)
				queue_free()
