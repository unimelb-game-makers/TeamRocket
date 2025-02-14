extends Camera2D

var in_aim_mode = false

var target_position: Vector2
var target_distance = 0
var center_pos = position

func _ready():
	connect("aim_mode_enter", Callable(self, "enter_aim_mode"))
	connect("aim_mode_exit", Callable(self, "exit_aim_mode"))
	
	target_position = position

func _process(delta: float) -> void:
	if in_aim_mode:
		var direction = center_pos.direction_to(get_local_mouse_position())
		var mouse_distance = center_pos.distance_to(get_local_mouse_position()) / 2
		target_position = center_pos + direction * mouse_distance
		
		target_position = target_position.clamp(
			center_pos - Vector2(20, 20), 
			center_pos + Vector2(20, 20)
		)
	else:
		target_position = position
	
	position = lerp(position, target_position, 5 * delta)

func enter_aim_mode():
	in_aim_mode = true

func exit_aim_mode():
	in_aim_mode = false
