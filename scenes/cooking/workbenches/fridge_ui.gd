extends Control

@onready var inventory_container: Container = $Background/InventoryArea/InventoryContainer
@onready var fridge_container: Container = $Background/FridgeArea/FridgeContainer

func _ready() -> void:
	reset()

func reset():
	inventory_container.update_inventory_list()
	fridge_container.update_inventory_list()
