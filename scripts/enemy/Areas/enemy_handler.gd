extends Node2D

@export var min_spawns_per_area: int = 1
@export var max_spawns_per_area: int = 1
@onready var spawn_areas: Node = $SpawnAreas

func _ready() -> void:
	for area in spawn_areas.get_children():
		var spawn_mob = randf() < 0.5
		if spawn_mob:
			var spawns = randi_range(min_spawns_per_area, max_spawns_per_area)
			area.spawn_batch(spawns)
