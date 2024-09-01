class_name Item
extends Node2D

@export var item_name: String
@export var item_weight: float

func delete_item() -> void:
	queue_free()
