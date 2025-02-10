extends Node

@export var spawns_per_area: int = 1
@onready var spawn_areas: Node = $SpawnAreas

func _ready() -> void:
	for area in spawn_areas.get_children():
		area.spawn_batch(spawns_per_area)
