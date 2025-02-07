extends TextureButton

@onready var food_label: Label = $FoodLabel
@onready var food_texture: Sprite2D = $FoodTexture

var index

signal remove_food(index)

func set_ingredient(item: Item):
	if (item):
		food_texture.texture = item.texture
	else:
		food_texture.texture = null

func _on_pressed() -> void:
	remove_food.emit(index)
