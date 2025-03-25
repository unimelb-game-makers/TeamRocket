extends Control
class_name MainUI

@onready var inventory_ui: InventoryUI = $Inventory

var inventory_container: Control

func _ready() -> void:
	inventory_container = inventory_ui.inventory_select_list
