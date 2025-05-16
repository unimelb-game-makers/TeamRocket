class_name StatusEffect
extends Resource

enum DurationCategory {
	INSTANT,
	SECONDS,
	DAYS,
	PERMANENT
}

@export var name: String

@export var duration: DurationCategory
@export var duration_int: int
@export var stackable: bool
@export var icon: Texture2D

# Apply is run when the status is first acquired
func apply(stats: PlayerStatsResource):
	return
	
# Remove is run when the status is removed from the player
func remove(stats: PlayerStatsResource):
	return

# Tick is run whenever a status ticks down (Either seconds or days)
func tick(stats: PlayerStatsResource):
	return
