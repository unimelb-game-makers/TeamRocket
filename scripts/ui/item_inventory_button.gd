extends Control

@onready var count_label: Label = $ItemButton/CountLabel
@onready var item_sprite: TextureRect = $ItemButton/ItemSprite

var item: Item
var amount: int

signal item_selected(item, amount)
signal item_hovered(item, amount)

func _ready() -> void:
	set_displays()

func set_displays() -> void:
	if item == null:
		return
	# item_label.text = item.item_name + " x" + str(amount)
	# weight_label.text = str(amount * item.weight) + "kg"
	count_label.text = " x" + str(amount)
	item_sprite.texture = item.texture

func _on_name_button_pressed() -> void:
	SoundManager.play_button_click_sfx()
	item_selected.emit(item, amount)

func _on_item_button_mouse_entered() -> void:
	SoundManager.play_button_hover_sfx()
	item_hovered.emit(item, amount)
