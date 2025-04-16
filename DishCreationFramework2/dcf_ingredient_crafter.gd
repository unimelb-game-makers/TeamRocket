class_name DCF_IngredientCrafter
extends Node

# If there is a method to just get all from a file
# where we store everything even better
# unless we check a set of recipes based on the cooking station
@export var all_ingredient_recipes: Array[DCF_IngredientRecipe]

func craft_ingredient(ingredients: Array[DCF_Ingredient]):
	var recipe: DCF_IngredientRecipe = match_ingredient_types(ingredients)
	if recipe != null:
		var resulting_ingredient = recipe.output_ingredient
		
		# THE IMPORTANT PART OF THE CRAFTING - influence result with inputs
		# Attach Buffs
		for ingredient in ingredients:
			for effect in ingredient.effects:
				resulting_ingredient.effects.append(effect)
		# TODO: Modify Name and Sprite based on...
		
		return resulting_ingredient
	else:
		print("Failed to craft any ingredient!")
		
func match_ingredient_types(ingredients: Array[DCF_Ingredient]) -> DCF_IngredientRecipe:
	# Grabbing all the ingredient types from ingredients input
	var ingredients_ingredient_type: Array[DCF_Ingredient.IngredientType] = []
	for ingredient in ingredients:
		ingredients_ingredient_type.append(ingredient.ingredient_type)
	
	# Finding exactly matching recipe based on ingredient types
	for recipe in all_ingredient_recipes:
		if ingredients.size() == recipe.input_ingredients.size():
			var ingredients_type_copy = ingredients_ingredient_type.duplicate()
			var recipe_copy = recipe.input_ingredients.duplicate()
			ingredients_type_copy.sort()
			recipe_copy.sort()
			if ingredients_type_copy == recipe_copy:
				return recipe.duplicate()
				
	return null
