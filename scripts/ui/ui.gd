extends Control

@onready var inventory: Control = $Inventory

var inventory_container: Control

func _ready() -> void:
	inventory_container = inventory.inventory_container
