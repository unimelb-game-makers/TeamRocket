class_name Activity
extends Resource

@export var recipes: Array[Recipe]
@export var max_ingredients: int

func match_recipe(items: Array[Item]) -> Recipe:
	for recipe in recipes:
		var matched_items = []
		var temp_items = items.duplicate(true)
		print(temp_items)
		for ingredient in recipe.required_items:
			print(ingredient)
			if temp_items.has(ingredient):
				matched_items.append(ingredient)
				temp_items.erase(ingredient)
			else:
				break
		if recipe.required_items == matched_items:
			return recipe
	return null
