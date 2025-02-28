@tool
extends Control

var item: Item
var path: String

@onready var texture_rect: TextureRect = $Button/TextureRect
@onready var label: Label = $Button/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_data()

func load_data() -> void:
	label.text = item.item_name
	texture_rect.texture = item.texture
