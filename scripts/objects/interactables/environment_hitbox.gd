extends Area2D

signal damaged(value: int)

func damage(value: int):
	damaged.emit(value)
