extends TextureButton

@onready var food_label: Label = $FoodLabel
var index

signal remove_food(index)

func set_ingredient(item: Item):
	food_label.text = item.item_name

func _on_pressed() -> void:
	remove_food.emit(index)
