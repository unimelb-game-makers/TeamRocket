@tool
extends Control

@onready var food_name_input: LineEdit = $FoodEditorUI/FoodNameInput
@onready var file_name_input: LineEdit = $FoodEditorUI/FileNameInput
@onready var weight_input: LineEdit = $FoodEditorUI/WeightInput
@onready var texture_button: TextureButton = $FoodEditorUI/TextureButton
@onready var description_input: TextEdit = $FoodEditorUI/DescriptionInput
@onready var rarity_option_button: OptionButton = $FoodEditorUI/RarityOptionButton

@onready var save_button: Button = $FoodEditorUI/SaveButton
@onready var delete_button: Button = $FoodEditorUI/DeleteButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func update_food_editor(item: Item, file: String) -> void:
	food_name_input.text = item.item_name
	file_name_input.text = file
	weight_input.text = str(item.weight)
	description_input.text = item.description
