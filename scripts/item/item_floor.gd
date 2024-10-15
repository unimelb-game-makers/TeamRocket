extends Node2D

@export var item: Item

func delete_item() -> void:
	queue_free()
