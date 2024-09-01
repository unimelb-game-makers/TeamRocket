extends Node

var inventory_array = []

func get_inventory() -> Array:
	return inventory_array
	
func add_item(item: String) -> void:
	inventory_array.append(item)
	
