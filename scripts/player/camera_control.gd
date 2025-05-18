extends Camera2D

var in_aim_mode = false

# Aiming mode
var original_position
var target_position: Vector2
var target_distance = 0
var max_distance_from_player = 500
var center_pos = position

# Shoot screen shake
var shake_strength: float = 0

func _ready():
	original_position = Vector2(position)
	target_position = position

func _process(delta: float) -> void:
	if in_aim_mode:
		var direction = center_pos.direction_to(get_local_mouse_position())
		var mouse_distance = center_pos.distance_to(get_local_mouse_position()) / 2
		target_position = center_pos + direction * mouse_distance
		
		target_position = target_position.clamp(
			center_pos - Vector2(max_distance_from_player, max_distance_from_player),
			center_pos + Vector2(max_distance_from_player, max_distance_from_player)
		)
	else:
		target_position = original_position
	
	position = lerp(position, target_position, 15 * delta)

func enter_aim_mode():
	in_aim_mode = true

func exit_aim_mode():
	in_aim_mode = false


func _on_player_aim_mode_enter() -> void:
	enter_aim_mode()


func _on_player_aim_mode_exit() -> void:
	exit_aim_mode()


func _on_rifle_fired() -> void:
	# Do screenshake when shoot here
	pass # Replace with function body.
