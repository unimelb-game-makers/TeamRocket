extends Control

@onready var inventory_container: Container = $Background/InventoryArea/InventoryContainer
@onready var fridge_container: Container = $Background/FridgeArea/FridgeContainer
@onready var item_name_label: Label = $Background/ItemDescriptionArea/ItemName
@onready var item_description_label: Label = $Background/ItemDescriptionArea/ItemDescription
@onready var item_image: TextureRect = $Background/ItemDescriptionArea/ItemImage

func _ready() -> void:
	reset()

func reset():
	inventory_container.update_inventory_list()
	fridge_container.update_inventory_list()
	clear_item_description_area_data()
	
func update_item_description_area(item: Item):
	item_name_label.text = item.item_name
	item_description_label.text = item.description
	item_image.texture = item.texture

func clear_item_description_area_data():
	item_name_label.text = ""
	item_description_label.text = ""
	item_image.texture = null

func _on_inventory_container_item_hover(item: Item, _amount: int) -> void:
	update_item_description_area(item)


func _on_fridge_container_item_hover(item: Item, _amount: int) -> void:
	update_item_description_area(item)
