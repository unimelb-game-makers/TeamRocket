extends Node2D

var leaf = preload("res://scenes/cooking/ingredients/CabbageLeaf.tscn")
var leaves_taken = 0
var leaves_limit = 8

@onready var orig_scale = Vector2(scale)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var new_leaf = leaf.instantiate()
			add_sibling(new_leaf)
			
			new_leaf.position = get_global_mouse_position()
			new_leaf.scale = orig_scale
			
			leaves_taken += 1
			
			# Scale down lettuce
			var new_scale = (1 - (float(leaves_taken) / leaves_limit)) * orig_scale
			scale = new_scale
		
		if leaves_taken == leaves_limit:
			queue_free()
