extends Control

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug") and Globals.allow_debug_tool:
		visible = !visible
