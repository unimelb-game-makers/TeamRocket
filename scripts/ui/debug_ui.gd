extends Control

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug") and OS.is_debug_build():
		visible = !visible
