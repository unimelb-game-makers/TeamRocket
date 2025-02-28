@tool
extends Control

var item: Item
var path: String

signal selected_item(item, path)

@onready var texture_rect: TextureRect = $Button/TextureRect
@onready var label: Label = $Button/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_data()

func load_data() -> void:
	label.text = item.item_name
	texture_rect.texture = item.texture

func _on_button_pressed() -> void:
	selected_item.emit(item, path)
