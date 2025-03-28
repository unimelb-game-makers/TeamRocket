extends Control
class_name MainUI

@onready var inventory_ui: InventoryUI = $Inventory
@onready var player_ui: PlayerUI = $PlayerUI

var inventory_container: Control

func _ready() -> void:
	inventory_container = inventory_ui.inventory_container
