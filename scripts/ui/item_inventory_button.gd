extends Control

@onready var food_label: Label = $FoodButton/FoodLabel
@onready var weight_label: Label = $FoodButton/WeightLabel

var item: Item
var amount: int

signal item_selected(item, amount)
signal item_dropped(item, amount)

func _ready() -> void:
	set_displays()

func set_displays() -> void:
	food_label.text = item.item_name + " x" + str(amount)
	weight_label.text = str(amount * item.weight) + "kg"

func _on_food_button_pressed() -> void:
	item_selected.emit(item, amount)

func _on_drop_button_pressed() -> void:
	item_dropped.emit(item, 1)
