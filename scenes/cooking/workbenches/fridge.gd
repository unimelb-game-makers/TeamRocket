extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var fridge_ui: Control = $CanvasLayer/FridgeUI

func _ready() -> void:
	sprite.material.set_shader_parameter("outline_color", Color.YELLOW)

func interact():
	if (fridge_ui.visible):
		fridge_ui.hide()
	else:
		fridge_ui.reset()
		fridge_ui.show()


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
