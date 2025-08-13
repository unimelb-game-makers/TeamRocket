extends Control

@onready var item_sprite: TextureRect = $ItemButton/ItemSprite

var item: Item
var amount: int
var recipe: Recipe

signal recipe_selected(recipe: Recipe)

func _ready() -> void:
	set_displays()

func set_displays() -> void:
	if item == null:
		return
	# item_label.text = item.item_name + " x" + str(amount)
	# weight_label.text = str(amount * item.weight) + "kg"
	item_sprite.texture = item.texture

func _on_name_button_pressed() -> void:
	SoundManager.play_button_click_sfx()
	recipe_selected.emit(recipe)

func _on_item_button_mouse_entered() -> void:
	SoundManager.play_button_hover_sfx()
