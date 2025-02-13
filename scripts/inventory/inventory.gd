extends Node

var inventory_array: Array[Item] = []
var inventory_dict: Dictionary = {}
var floor_item_scene: PackedScene = preload("res://scenes/item/item_floor.tscn")

func get_inventory() -> Dictionary:
	return inventory_dict
	
func add_item(item: Item, amount) -> void:
	#inventory_array.append(item)
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
	var ui = get_tree().get_first_node_in_group("ui")
	var inventory_ui = ui.inventory_container
	inventory_ui.update_inventory_list()
	#ui.inventory_label.text = "Inventory: " + str(get_total_weight()) + "kg"

func get_total_weight() -> float:
	var total: float = 0
	for item in inventory_dict:
		total += item.weight * inventory_dict[item]
	return total
	
func drop_item(item: Item, amount: int) -> void:
	if (has_item(item, amount)):
		remove_item(item, amount)
		var dropped_item = floor_item_scene.instantiate()
		dropped_item.item = item
		dropped_item.amount = amount
		dropped_item.global_position = Globals.player.global_position
		Globals.item_handler.add_child(dropped_item)
