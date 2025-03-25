extends Control

@onready var button: BaseButton = $TextureButton
@onready var food_label: Label = $TextureButton/FoodLabel
@onready var food_texture: TextureRect = $TextureButton/FoodTexture

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
	SoundManager.play_button_click_sfx()
	food_removed.emit(index)


func play_button_hover_sfx():
	SoundManager.play_button_hover_sfx()