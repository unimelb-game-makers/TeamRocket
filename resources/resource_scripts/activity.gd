class_name Activity
extends Resource

@export var recipes: Array[Recipe]
@export var max_ingredients: int

func match_recipe(items: Array[Item]) -> Recipe:
	for recipe in recipes:
		if items == recipe.required_items:
			return recipe
	return null
