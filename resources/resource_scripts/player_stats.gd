class_name PlayerStatsResource
extends Resource

var SPRINT_MULTIPLIER = 2.0
var CROUCH_MULTIPLIER = 0.5

@export var max_health: int
var health:
	set(value):
		health = value
		if (health > max_health):
			health = max_health

@export var damage: int
@export var level: int

@export var speed: float:
	set(value):
		speed = value
		run_speed = speed * SPRINT_MULTIPLIER
		crouch_speed = speed * CROUCH_MULTIPLIER

var run_speed: float = speed * SPRINT_MULTIPLIER
var crouch_speed: float = speed * CROUCH_MULTIPLIER
@export var acceleration: float

# Load stats from save file
func load_stats(stats: Dictionary):
	level = stats["level"]
	max_health = stats["max_health"]
	health = stats["health"]
	speed = stats["speed"]
	damage = stats["damage"]
	level = stats["level"]
	
func export_stats():
	var stats = {
		"max_health": max_health,
		"health": health,
		"speed": speed,
		"damage": damage,
		"level": level
	}
	return stats

# Reset stats to base stats
func reset_stats():
	pass
