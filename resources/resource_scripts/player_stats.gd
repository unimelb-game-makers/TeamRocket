class_name PlayerStatsResource
extends Resource

const SPRINT_MULTIPLIER = 2.0
const CROUCH_MULTIPLIER = 0.5

@export var level: int
@export var max_health: int
@export var health: int:
	set(value):
		health = value
		if (health > max_health):
			health = max_health
@export var damage: int
@export var speed: float:
	set(value):
		speed = value
		run_speed = speed * SPRINT_MULTIPLIER
		crouch_speed = speed * CROUCH_MULTIPLIER
		
		accel = speed / 5
		run_accel = run_speed / 5
		crouch_accel = crouch_speed / 5

var run_speed: float = speed * SPRINT_MULTIPLIER
var crouch_speed: float = speed * CROUCH_MULTIPLIER

var accel: float = speed / 5
var run_accel: float = run_speed / 5
var crouch_accel: float = crouch_speed / 5

# Enemies within this range can be detected by player when they crouch
var hearing_sensitivity = 4000

# Load stats from save file
func load_stats(stats: Dictionary):
	level = stats["level"]
	max_health = stats["max_health"]
	health = stats["health"]
	damage = stats["damage"]
	speed = stats["speed"]
	
func export_stats():
	var stats = {
		"level": level,
		"max_health": max_health,
		"health": health,
		"damage": damage,
		"speed": speed,
	}
	return stats

# Reset stats to base stats
func reset_stats():
	level = 1
	max_health = 50
	health = 50
	damage = 5
	speed = 200
