extends TextureRect

@export var eye_only_texture: TextureRect

var max_pupil_distance = 3

const DISTANCE_COEEFICIENT = 0.01

func _process(_delta):
	var portrait_center = global_position + (size / 2)
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - portrait_center).normalized()
	var distance = portrait_center.distance_to(mouse_position) * DISTANCE_COEEFICIENT
	var pupil_distance = min(distance, max_pupil_distance)
	eye_only_texture.position = direction * pupil_distance
