extends Node2D

@export var randomized_wind_sway = true

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if randomized_wind_sway:
		var rand_offset = randf_range(0, 100)
		sprite.material.set_shader_parameter('offset', rand_offset)