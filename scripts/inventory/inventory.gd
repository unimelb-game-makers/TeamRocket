extends Node

var inventory_array: Array[Item] = []

func get_inventory() -> Array:
	return inventory_array
	
func add_item(item: Item) -> void:
	inventory_array.append(item)
	
	# Update UI 
	var ui = get_tree().get_first_node_in_group("ui")
	print(ui)
	var inventory_ui = ui.inventory_container
	inventory_ui.update_inventory()
