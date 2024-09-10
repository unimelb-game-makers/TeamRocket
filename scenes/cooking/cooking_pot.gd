extends Sprite2D

var dragged_object = null

func _on_spoon_clicked(obj) -> void:
	if !dragged_object:
		dragged_object = obj
		dragged_object.pickup()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if dragged_object and !event.pressed:
			dragged_object.drop(Input.get_last_mouse_velocity())
			dragged_object = null
