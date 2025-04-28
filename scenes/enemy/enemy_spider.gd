extends BasicEnemy

# From 0 to 1
@export var dodge_chance_when_defend = 0.5

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

const DEFENDING_MOVESPEED_COEFFICIENT = 0.25

func _on_chase_state_physics_processing(delta: float) -> void:
	if target_creature != null:
		if target_creature is Player:
			var target_player = target_creature as Player
			if target_player.is_aiming:
				movement_speed = active_speed * DEFENDING_MOVESPEED_COEFFICIENT
			else:
				movement_speed = active_speed
	super (delta)


func damage(value: int) -> void:
	var dodge_roll = randf_range(0, 1)
	if dodge_roll < dodge_chance_when_defend:
		play_dodge_effect()
		return
	super (value)

func play_dodge_effect():
	var tween = create_tween()
	tween.tween_property(anim_sprite, "modulate:a", 0.5, 0.2)
	tween.tween_property(anim_sprite, "modulate:a", 1, 0.2)
