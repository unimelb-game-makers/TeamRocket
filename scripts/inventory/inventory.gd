extends Node

var inventory_array: Array[Item] = []
var inventory_dict: Dictionary = {}

func get_inventory() -> Array:
	return inventory_array
	
func add_item(item: Item) -> void:
	inventory_array.append(item)
	
	# Update UI 
	var ui = get_tree().get_first_node_in_group("ui")
	var inventory_ui = ui.inventory_container
	inventory_ui.update_inventory_list()
	ui.inventory_label.text = "Inventory: " + str(get_total_weight()) + "kg"

func get_total_weight() -> float:
	var total: float = 0
	for item in inventory_array:
		total += item.weight
	return total
