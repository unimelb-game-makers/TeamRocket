extends Node2D
class_name CabbageLeaf

var selected : bool = false
var offset : Vector2 = Vector2.ZERO

signal placed_down(pos: Vector2)

func _process(delta: float) -> void:
	if selected:
		position = get_global_mouse_position() - offset

func _on_button_button_down() -> void:
	selected = true
	offset = get_global_mouse_position() - global_position

func _on_button_button_up() -> void:
	selected = false
	placed_down.emit(global_position)
