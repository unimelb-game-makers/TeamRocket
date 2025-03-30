class_name Ingredient
extends Item

enum IngredientType {
	None, Vegetable, Meat, Fish, Other
}

@export var ingredient_type: IngredientType
@export var player_status_effects: Array
@export var gun_status_effects: Array

# [{"id": "damage_up", "duration": 2, "amplifier": 1}]
