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

func add_item(item: Item) -> void:
	if (len(selected_ingredients) < max_slots):
		selected_ingredients.append(item)
		Inventory_Global.remove_item(item, 1)
		
		update_slots()

func update_slots() -> void:
	# KILL ALL CHILDREN
	for child in get_children():
		child.queue_free()
		
	for i in range(max_slots):
		var slot = food_slot_scene.instantiate()
		add_child(slot)
		if (i < len(selected_ingredients)):
			slot.set_ingredient(selected_ingredients[i])
