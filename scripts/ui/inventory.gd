extends Control

signal item_selected(item, amount)

@onready var inventory_container: CenterContainer = $ItemListBackground/InventoryContainer
@onready var item_descriptor: ColorRect = $ItemDescriptionBackground

func update_weight_label():
	pass

func _on_inventory_container_item_selected(item: Item, amount: int) -> void:
	item_selected.emit(item, amount)
	item_descriptor.update_description_info(item)
