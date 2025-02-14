extends Control

signal back

func _on_button_pressed() -> void:
	back.emit()
