extends Node2D

var angle = 0
@export var width: float = 5
@export var point_count: int = 30
@export var color: Color = Color("ffffff3d")
@export var radius: float = 60

func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, deg_to_rad(-angle), deg_to_rad(angle), point_count, color, width, true)
