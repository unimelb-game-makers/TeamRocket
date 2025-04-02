class_name Activity
extends Resource

@export var recipes: Array[Recipe]
@export var max_ingredients: int

func match_recipe(items: Array[Ingredient]) -> Recipe:
	for recipe in recipes:
		if recipe.generate_item(items):
			return recipe
	return null
