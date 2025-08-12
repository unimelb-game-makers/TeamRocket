extends Node2D

@export var randomized_wind_sway = true

@onready var sprite: Sprite2D = $Sprite2D

const ROTATE_STRENGTH = 4.0
const ROTATE_DURATION = 0.2

var tween: Tween = null

func _ready() -> void:
	if randomized_wind_sway:
		var rand_offset = randf_range(0, 100)
		sprite.material.set_shader_parameter('offset', rand_offset)


func shake():
	if tween != null and tween.is_running():
		return # Avoid stacking tweens

	tween = create_tween()

	var original_rotation = rotation_degrees
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Move slightly left and right then return
	var rand_rotate_strenth = ROTATE_STRENGTH * randf_range(-1, 1)
	var rand_rotate_duration = ROTATE_DURATION * randf_range(0.75, 1.25)
	tween.tween_property(sprite, "rotation_degrees", original_rotation + rand_rotate_strenth, rand_rotate_duration)
	tween.tween_property(sprite, "rotation_degrees", original_rotation - rand_rotate_strenth, rand_rotate_duration)
	tween.tween_property(sprite, "rotation_degrees", original_rotation, rand_rotate_duration)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		body.is_hidden_count -= 1

func _on_area_2d_body_entered(body: Node2D) -> void:
	shake()
	if body is Player:
		body.is_hidden_count += 1
