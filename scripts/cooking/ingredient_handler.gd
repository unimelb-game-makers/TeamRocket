extends Control

var selected_ingredients: Array[Item]
var max_slots = 1
@export var food_slot_scene: PackedScene

func ready() -> void:
	pass

func create_slots() -> void:
	# KILL ALL CHILDREN
	for child in get_children():
		child.queue_free()
		
	for i in range(max_slots):
		var slot = food_slot_scene.instantiate()
		add_child(slot)
