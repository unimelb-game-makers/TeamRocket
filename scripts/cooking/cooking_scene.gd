class_name CookingScene extends Node2D

@onready var activity = %Activity

signal complete(output)

func _ready() -> void:
	activity.complete.connect(finish)
	
func finish():
	print("Chop Signal Received")
	complete.emit()
