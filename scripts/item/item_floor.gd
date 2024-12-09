extends Node2D

@export var item: Item
@export var amount: int = 1

func delete_item() -> void:
	queue_free()
