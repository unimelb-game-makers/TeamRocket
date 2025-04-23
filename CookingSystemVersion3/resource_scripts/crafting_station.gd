class_name CraftingStation
extends Node

# Equivalent to DCFDishCrafter/Activity Station
@export var recipes: Array[Recipe]

# Returns either an ingredient output or a food output dependent on recipe
func craft_output(ingredients: Array[Ingredient]) -> Item:
	# First get matching recipe
	var output_recipe: Recipe = match_base_ingredient_types(ingredients)
	# Process it depending on if it is an ingredient or dish output
	if (output_recipe is IngredientRecipe):
		# If ingredient, just return the output ingredient
		print(output_recipe.output_ingredient.item_name)
		return output_recipe.output_ingredient
	elif (output_recipe is DishRecipe):
		# If output is a dish, then match variants, add effects (based on ingredients) and output final result
		var output_dish = match_variant(ingredients, output_recipe)
		# Adding base and ingredient status effects
		for effect in output_recipe.effects:
			output_dish.effects.append(effect)
		for ingredient in ingredients:
			for effect in ingredient.effects:
				output_dish.dish_effects.append(effect)
		return output_dish
	return

#func craft_dish(ingredients: Array[DCF_Ingredient]) -> DCF_Dish:
	#var dish_type: DCF_DishType = match_base_ingredient_types(ingredients)
	#if dish_type != null:
		## Check if there is a known variant
		#var dish_variant: DCF_Dish = match_variant_ingredient_types(ingredients, dish_type)
		#
		## THE IMPORTANT PART OF THE CRAFTING - influence result with inputs
		## Attach Buffs | note: dish variant intrinsic buffs are already inside
		#for ingredient in ingredients:
			#for effect in ingredient.effects:
				#dish_variant.dish_effects.append(effect)
				#
		#for effect in dish_type.dishtype_effects:
			#dish_variant.dish_effects.append(effect)
			#
		## TODO: Modify Name and Sprite based on...
		#return dish_variant
		#
	#else:
		#print("Failed to craft dish!")
		#return null
		
func match_base_ingredient_types(ingredients: Array[Ingredient]) -> Recipe:
	# Grabbing all the ingredient types from ingredients input
	var ingredients_type: Dictionary = {}

	# Making Tally of ingredients provided
	for ingredient in ingredients:
		var i = ingredient.ingredient_type
		ingredients_type[i] = ingredients_type.get(i, 0) + 1 # the .get returns the value in dict or 0 if does not exist
	
	# Finding exactly matching recipe based on ingredient types
	for recipe in recipes:
		# Making Tally of ingredients for base recipe
		var dish_type_ingredients: Dictionary = {}
		for ingredient_type in recipe.base_ingredients:
			var j = ingredient_type
			dish_type_ingredients[j] = dish_type_ingredients.get(j, 0) + 1 # the .get returns the value in dict or 0 if does not exist
		
		# Check tally that ingredients enough for base
		var is_enough = true
		for ingredient_type in dish_type_ingredients.keys():
			if dish_type_ingredients[ingredient_type] > ingredients_type.get(ingredient_type, 0): # If the base dish requirees more for that ingredient than given
				is_enough = false
				break
		if is_enough:
			return recipe
	return null

func match_variant(ingredients: Array[Ingredient], recipe: DishRecipe) -> Dish:
	# Grabbing all the ingredient types from ingredients input
	var ingredients_ingredient_type: Array[DCF_Ingredient.IngredientType] = []
	for ingredient in ingredients:
		ingredients_ingredient_type.append(ingredient.ingredient_type)
	
	# Finding exactly matching recipe based on ingredient types
	for dish in recipe.dishes:
		var ingredients_type_copy = ingredients_ingredient_type.duplicate()
		var dish_copy = dish.ingredients.duplicate()
		dish_copy += recipe.base_ingredients.duplicate()
		ingredients_type_copy.sort()
		dish_copy.sort()
		if ingredients_type_copy == dish_copy:
			return dish.duplicate()
	
	# No known variant
	# We can have the first variant in list to a generic, technically this line would not be needed,  
	# but just incase we set no generic where no extra ingredients needed
	var dish = recipe.dishes[0].duplicate()
	return dish
