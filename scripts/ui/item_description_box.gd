extends Control
class_name ItemDescriptionBox

@onready var item_name: Label = $ItemName
@onready var item_desc: Label = $ItemDesc
@onready var item_image: TextureRect = $ItemImage


func _ready() -> void:
	reset_display()

func update_description_info(item: Item):
	item_name.text = str(item)
	item_desc.text = item.description.c_unescape()
	item_image.texture = item.texture

func reset_display():
	item_name.text = ""
	item_desc.text = ""
	item_image.texture = null
