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

@export var food_res_folder: String

var editing_item: Item

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func update_food_editor(item: Item, file: String) -> void:
	food_name_input.text = item.item_name
	file_name_input.text = file
	weight_input.text = str(item.weight)
	texture_button.texture_normal = item.texture
	description_input.text = item.description
	editing_item = item.duplicate()

func _on_texture_button_pressed() -> void:
	print("Want to change texture")

func _on_save_button_pressed() -> void:
	print("Saving Resource")
	editing_item.item_name = food_name_input.text
	editing_item.weight = float(weight_input.text)
	editing_item.texture = texture_button.texture_normal
	editing_item.description = description_input.text
	ResourceSaver.save(editing_item, food_res_folder + file_name_input.text)

func _on_delete_button_pressed() -> void:
	print("Are you sure you want to do that?")
	pass
