extends Control

@onready var inventory_container: VBoxContainer = %InventoryContainer
@onready var cooking_handler: Control = $CanvasLayer/CookingHandler


func _on_player_activity_interact(activity: Variant) -> void:
	cooking_handler.init_activity(activity)
