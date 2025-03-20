extends TextureButton

@onready var food_label: Label = $FoodLabel
@onready var food_texture: Sprite2D = $FoodTexture

var index

signal food_removed(index)

func set_ingredient(item: Item):
	if (item):
		food_texture.texture = item.texture
	else:
		food_texture.texture = null

func remove_food():
	food_removed.emit(index)

func _on_pressed() -> void:
	food_removed.emit(index)
