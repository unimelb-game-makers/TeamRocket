extends Control

@onready var inventory: Control = $CanvasLayer/Inventory

@onready var cooking_handler: Control = $CanvasLayer/CookingHandler
var inventory_container: Control

func _ready() -> void:
	inventory_container = inventory.inventory_container

func _on_player_activity_interact(activity: Variant) -> void:
	cooking_handler.init_activity(activity)
