extends Control

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("debug")):
		visible = !visible
