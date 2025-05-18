class_name AttackIncreaseStatus
extends StatusEffect

@export var attack_increase: int

func apply(stats: PlayerStatsResource):
	stats.damage += attack_increase
	return
	
func remove(stats: PlayerStatsResource):
	stats.damage -= attack_increase
	return
