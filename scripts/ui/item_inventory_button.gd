extends Control

@onready var item_label: Label = $NameButton/ItemLabel
@onready var weight_label: Label = $NameButton/WeightLabel
@onready var item_sprite: Sprite2D = $ItemButton/ItemSprite

var item: Item
var amount: int

signal item_selected(item, amount)
signal item_dropped(item, amount)

func _ready() -> void:
	set_displays()
 	
func set_displays() -> void:
	if item == null:
		return
	item_label.text = item.item_name + " x" + str(amount)
	weight_label.text = str(amount * item.weight) + "kg"
	item_sprite.texture = item.texture

func _on_drop_button_pressed() -> void:
	item_dropped.emit(item, 1)

func _on_name_button_pressed() -> void:
	item_selected.emit(item, amount)
