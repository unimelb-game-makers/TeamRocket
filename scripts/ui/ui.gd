extends Control

@onready var inventory: Control = $CanvasLayer/Inventory

var inventory_container: Control

func _ready() -> void:
	inventory_container = inventory.inventory_container
