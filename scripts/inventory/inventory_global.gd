extends Node

var inventory_dict: Dictionary = {}
var floor_item_scene: PackedScene = preload("res://scenes/item/ItemOnFloor.tscn")

func get_inventory() -> Dictionary:
	return inventory_dict
	
func add_item(item: Item, amount) -> void:
	if (inventory_dict.has(item)):
		inventory_dict[item] += amount
	else:
		inventory_dict[item] = amount
	
	update_ui()
	
func remove_item(item: Item, amount: int) -> void:
	if (has_item(item, amount)):
		inventory_dict[item] -= amount
	
		if (inventory_dict[item] == 0):
			inventory_dict.erase(item)
			
	update_ui()

func has_item(item: Item, amount: int) -> bool:
	if (inventory_dict.has(item)):
		if (inventory_dict[item] >= amount):
			return true
	return false

func update_ui() -> void:
	var inventory_ui = Globals.inventory_ui
	inventory_ui.inventory_select_list.update_inventory_list()
	inventory_ui.update_weight_label()
	#ui.inventory_label.text = "Inventory: " + str(get_total_weight()) + "kg"

func get_total_weight() -> float:
	var total: float = 0
	for item in inventory_dict:
		total += item.weight * inventory_dict[item]
	return total

## Drop items to the ground and return the amount of that item left. Return -1 if operation failed.
func drop_item(item: Item, amount: int) -> int:
	if (has_item(item, amount)):
		remove_item(item, amount)
		var dropped_item = floor_item_scene.instantiate()
		dropped_item.item = item
		dropped_item.amount = amount
		# Randomize spawn position to avoid dropped item overlapp a bit
		var rand_x = randf_range(-100, 100)
		var rand_y = randf_range(-100, 100)
		Globals.item_handler.add_child(dropped_item)
		dropped_item.global_position = Globals.player.feet_position_marker.global_position + Vector2(rand_x, rand_y)
		if (inventory_dict.has(item)):
			return inventory_dict[item]
		else:
			return 0
	return -1

func reset_save_data():
	inventory_dict = {}