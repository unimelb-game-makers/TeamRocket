extends ColorRect
@onready var item_name: Label = $ItemName
@onready var item_desc: Label = $ItemDesc
@onready var item_image: TextureRect = $ItemImage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_description_info(item: Item):
	item_name.text = item.item_name
	item_desc.text = item.description
	item_image.texture = item.texture
