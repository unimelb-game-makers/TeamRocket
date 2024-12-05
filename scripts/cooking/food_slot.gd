extends TextureButton

@onready var food_label: Label = $FoodLabel

func set_ingredient(item: Item):
	food_label.text = item.item_name
