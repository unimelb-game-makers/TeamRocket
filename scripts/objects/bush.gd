extends Node2D

@export var randomized_wind_sway = true
@export var sprites: Array[Sprite2D]

const ROTATE_STRENGTH = 4.0
const ROTATE_DURATION = 0.2

func _ready() -> void:
	if randomized_wind_sway:
		var rand_offset = randf_range(0, 100)
		for sprite in sprites:
			sprite.material.set_shader_parameter('offset', rand_offset)


func shake(sprite: Sprite2D):
	var tween = create_tween()

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
	for sprite in sprites:
		shake(sprite)
	if body is Player:
		body.is_hidden_count += 1
