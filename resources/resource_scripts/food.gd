class_name Food 
extends Item

@export var food_value: int # Amount of hunger(?) that it will replenish

@export var player_status_effects: Array
@export var gun_status_effects: Array

func export_save() -> Dictionary:
	pass
	return {}
