extends VBoxContainer

var is_open = false

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("inventory")):
		visible = not visible
		is_open = visible
