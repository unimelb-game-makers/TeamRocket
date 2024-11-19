extends VBoxContainer

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("inventory")):
		print("Test")
		visible = not visible
