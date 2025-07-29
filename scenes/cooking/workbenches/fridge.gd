extends Area2D

@export var debug_mode: bool = false
@export var debug_bonus_item: Array[Item] = []

@onready var sprite: Sprite2D = $Sprite2D
@onready var fridge_ui: Control = $CanvasLayer/FridgeUI

func _ready() -> void:
	sprite.material.set_shader_parameter("outline_color", Color.YELLOW)
	fridge_ui.visible = false
	if debug_mode:
		for item in debug_bonus_item:
			InventoryGlobal.add_item(item, 10, InventoryGlobal.InventoryType.FRIDGE)

func interact():
	if (fridge_ui.visible):
		fridge_ui.hide()
		Globals.inventory_ui.can_open = true
	else:
		fridge_ui.reset()
		fridge_ui.show()
		Globals.inventory_ui.can_open = false


func _on_fridge_container_item_select(item: Item, _amount: int) -> void:
	InventoryGlobal.remove_item(item, 1, InventoryGlobal.InventoryType.FRIDGE)
	InventoryGlobal.add_item(item, 1, InventoryGlobal.InventoryType.PLAYER)
	fridge_ui.reset()

func _on_inventory_container_item_select(item: Item, _amount: int) -> void:
	InventoryGlobal.remove_item(item, 1, InventoryGlobal.InventoryType.PLAYER)
	InventoryGlobal.add_item(item, 1, InventoryGlobal.InventoryType.FRIDGE)
	fridge_ui.reset()


func _on_area_exited(_area: Area2D) -> void:
	fridge_ui.hide()
	sprite.material.set_shader_parameter("outline_color", Color.YELLOW)

func _on_area_entered(_area: Area2D) -> void:
	sprite.material.set_shader_parameter("outline_color", Color.GREEN)
