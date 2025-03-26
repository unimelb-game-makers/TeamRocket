extends Node

enum InventoryType {
	NONE,
	PLAYER,
	FRIDGE
}
# Player inventory
var inventory_dict: Dictionary = {
	0: null, # NONE
	1: {}, # PLAYER
	2: {} # FRIDGE
}
var floor_item_scene: PackedScene = preload("res://scenes/item/ItemOnFloor.tscn")

func get_inventory(type: InventoryType = InventoryType.PLAYER) -> Dictionary:
	return inventory_dict[type]

func update_ui() -> void:
	var inventory_ui = Globals.inventory_ui
	inventory_ui.inventory_container.update_inventory_list()
	inventory_ui.update_weight_label()
	
func add_item(item: Item, amount: int, type: InventoryType = InventoryType.PLAYER) -> void:
	if (inventory_dict[type].has(item)):
		inventory_dict[type][item] += amount
	else:
		inventory_dict[type][item] = amount
	update_ui()

func has_item(item: Item, amount: int, type: InventoryType = InventoryType.PLAYER) -> bool:
	if (inventory_dict[type].has(item)):
		if (inventory_dict[type][item] >= amount):
			return true
	return false

func remove_item(item: Item, amount: int, type: InventoryType = InventoryType.PLAYER) -> void:
	if (has_item(item, amount, type)):
		inventory_dict[type][item] -= amount
		if (inventory_dict[type][item] == 0):
			inventory_dict[type].erase(item)
	update_ui()


func get_total_weight(type: InventoryType = InventoryType.PLAYER) -> float:
	var total: float = 0
	for item in inventory_dict[type]:
		total += item.weight * inventory_dict[type][item]
	return total

## Drop items to the ground and return the amount of that item left. Return -1 if operation failed.
func drop_item(item: Item, amount: int, type: InventoryType = InventoryType.PLAYER) -> int:
	if (has_item(item, amount, type)):
		remove_item(item, amount, type)
		var dropped_item = floor_item_scene.instantiate()
		dropped_item.item = item
		dropped_item.amount = amount
		# Randomize spawn position to avoid dropped item overlap a bit
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
	inventory_dict = {
		0: null,
		1: {},
		2: {}
	}
