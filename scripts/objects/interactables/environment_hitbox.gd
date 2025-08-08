extends Area2D

signal damaged(value: int, damage_source_position: Vector2)

func damage(value: int, damage_source_position: Vector2 = Vector2.ZERO):
	damaged.emit(value, damage_source_position)
