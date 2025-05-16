class_name HealthIncreaseStatus
extends StatusEffect

@export var health_increase: int

func apply(stats: PlayerStatsResource):
	stats.max_health += health_increase
	stats.health += health_increase
	return
	
func remove(stats: PlayerStatsResource):
	stats.max_health -= health_increase
	stats.health -= health_increase
	return
