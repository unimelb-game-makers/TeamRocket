class_name PlayerStatsResource
extends Resource

const SPRINT_MULTIPLIER = 2.0
const CROUCH_MULTIPLIER = 0.5

@export var level: int = 1
@export var max_health: int = 100
@export var health: int = 100:
	set(value):
		health = value
		if (health > max_health):
			health = max_health
		if (Globals):
			if (Globals.player_ui):
				Globals.player_ui.update_health(health, max_health)
@export var damage: int = 10
@export var speed: float = 200:
	set(value):
		speed = value
		run_speed = speed * SPRINT_MULTIPLIER
		crouch_speed = speed * CROUCH_MULTIPLIER
		
		accel = speed / 5
		run_accel = run_speed / 5
		crouch_accel = crouch_speed / 5

# Status Effects listed by duration (Either in seconds or days, -1 if instant or permanent)
# Status Effect Structure:
# Dictionary with status_effect as key, value is an array structured [duration, stacks]
@export var status_effects: Dictionary

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
	for status in stats["status_effects"]:
		var status_inst = load(status["status"])
		status_effects[status_inst] = [status["duration"], status["stacks"]]
	
func export_stats():
	var status_arr = []
	for status: StatusEffect in status_effects:
		var status_info = {
			"status": status.resource_path,
			"duration": status_effects[status][0],
			"stacks": status_effects[status][1],
			}
		status_arr.append(status_info)
	var stats = {
		"level": level,
		"max_health": max_health,
		"health": health,
		"damage": damage,
		"speed": speed,
		"status_effects": status_arr
	}
	print(stats)
	return stats

# Reset stats to base stats
func reset_stats():
	level = 1
	max_health = 100
	health = 100
	damage = 5
	speed = 200

func tick_status_effects(duration: StatusEffect.DurationCategory):
	# Status effects should only tick if they are duration based (SECONDS, DAYS)
	for status in status_effects.keys():
		if (status.duration == duration):
			status_effects[status][0] -= 1
			for stack in range(status_effects[status][1]):
				status.tick(self)
			if (status_effects[status][0] <= 0):
				status.remove(self)
				status_effects.erase(status)
	Globals.inventory_ui.update_character_stats()
	Globals.inventory_ui.update_status_panel()

func apply_status(status: StatusEffect):
	if (status.duration == StatusEffect.DurationCategory.INSTANT):
		status.apply(self)
		return
	if (status not in status_effects.keys()):
		status.apply(self)
		status_effects[status] = [status.duration_int, 1]
	elif (status.stackable):
		status.apply(self)
		status_effects[status][1] += 1
		status_effects[status][0] = status.duration_int
	# Do not apply status if it is not stackable and already on the player
	Globals.inventory_ui.update_character_stats()
	Globals.inventory_ui.update_status_panel()
