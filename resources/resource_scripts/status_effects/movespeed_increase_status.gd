class_name MovespeedIncreaseStatus
extends StatusEffect

@export var speed_increase: int

func apply(stats: PlayerStatsResource):
	stats.speed += speed_increase
	return
	
func remove(stats: PlayerStatsResource):
	stats.speed -= speed_increase
	return
