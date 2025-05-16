class_name RegenerationStatus
extends StatusEffect

@export var health_per_tick: int

func tick(stats: PlayerStatsResource):
	stats.health += health_per_tick
	return
