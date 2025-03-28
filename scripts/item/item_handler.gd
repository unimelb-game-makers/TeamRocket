extends Node

func _ready() -> void:
	# TODO: Fix YSort so player dont get draw 
	# over item even if he is in front of item
	Globals.item_handler = self
