class_name Activity
extends Resource

@export var recipes: Array[Recipe]
@export var max_ingredients: int

func match_recipe(items: Array[Ingredient]) -> Recipe:
	print("Matching Recipe")
	for recipe in recipes:
		print(recipe)
		if recipe.generate_item(items):
			print("Recipe Found")
			return recipe
	return null
