extends NinePatchRect
@onready var item_name: Label = $ItemName
@onready var item_desc: Label = $ItemDesc
@onready var item_image: TextureRect = $ItemImage


func _ready() -> void:
	item_name.text = ""
	item_desc.text = ""
	item_image.texture = null

func update_description_info(item: Item):
	item_name.text = item.item_name
	item_desc.text = item.description.c_unescape()
	item_image.texture = item.texture
