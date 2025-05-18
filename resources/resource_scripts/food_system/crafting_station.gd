class_name CraftingStation
extends Resource

# Equivalent to DCFDishCrafter/Activity Station
@export var recipes: Array[Recipe]
@export var max_ingredients = 1

# Returns either an ingredient output or a food output dependent on recipe
func craft_output(input_ingredients: Array[Ingredient]) -> Item:
	# First get matching recipe
	var output_recipe: Recipe = match_base_ingredient_types(input_ingredients, true)
	if output_recipe == null:
		print("output_recipe null, try less strict match")
		output_recipe = match_base_ingredient_types(input_ingredients)
	# Process it depending on if it is an ingredient or dish output

	if (output_recipe is IngredientRecipe):
		# If ingredient, just return the output ingredient
		return output_recipe.output_ingredient
	elif (output_recipe is DishRecipe):
		# If output is a dish, then match variants, add effects (based on ingredients) and output final result
		var output_dish = match_variant(input_ingredients, output_recipe)
		output_dish.ingredients.clear()
		# Adding base and ingredient status effects
		for effect in output_recipe.effects:
			output_dish.effects.append(effect)
		for ingredient in input_ingredients:
			output_dish.ingredients.append(ingredient)
			for effect in ingredient.effects:
				output_dish.dish_effects.append(effect)
		return output_dish
	else:
		print("No such recipe exist") # TODO: Showing this visually to the player is needed
		return
		
## We used `exact_number_of_ingredients` to make sure we can search for recipe that use same type of ingredients but
## with different amount. Example: Cut Carrot need 1 Carrot while Carrot Powder need 2 Carrot.
func match_base_ingredient_types(ingredients: Array[Ingredient], exact_number_of_ingredients = false) -> Recipe:
	print("match_base_ingredient_types ==================================")
	# Grabbing all the ingredient types from ingredients input
	var ingredients_type_input_dict: Dictionary = {}

	# Making Tally of ingredients provided
	for ingredient in ingredients:
		var ingredient_type = ingredient.ingredient_type
		# the .get returns the value in dict or 0 if does not exist
		ingredients_type_input_dict[ingredient_type] = ingredients_type_input_dict.get(ingredient_type, 0) + 1

	# Finding exactly matching recipe based on ingredient types
	for recipe in recipes:
		print("Recipe name ", recipe.recipe_name)
		# Making Tally of ingredients for base recipe
		var recipe_base_ingredient_dict: Dictionary = {}
		for ingredient_type in recipe.base_ingredients:
			recipe_base_ingredient_dict[ingredient_type] = recipe_base_ingredient_dict.get(ingredient_type, 0) + 1

		# Check tally that ingredients enough for base
		var output_dish_matched = true
		print("recipe_base_ingredient_dict ", recipe_base_ingredient_dict)
		print("ingredients_type_input_dict ", ingredients_type_input_dict)
		for ingredient_type in recipe_base_ingredient_dict.keys():
			if exact_number_of_ingredients:
				# If the base dish required different amount for that ingredient than given
				if recipe_base_ingredient_dict[ingredient_type] != ingredients_type_input_dict.get(ingredient_type, 0):
					output_dish_matched = false
					break
			else:
				# If the base dish required more for that ingredient than given
				if recipe_base_ingredient_dict[ingredient_type] > ingredients_type_input_dict.get(ingredient_type, 0):
					output_dish_matched = false
					break
	
		# Check for swappable ingredient if is full DishRecipe
		if recipe is DishRecipe:
			 # Remove base ingredients from input ingredients dict
			var filtered_ingredients_type_input_dict = ingredients_type_input_dict.duplicate()
			for key in recipe_base_ingredient_dict.keys():
				if filtered_ingredients_type_input_dict.has(key):
					filtered_ingredients_type_input_dict[key] -= recipe_base_ingredient_dict[key]
					if filtered_ingredients_type_input_dict[key] <= 0:
						filtered_ingredients_type_input_dict.erase(key)
			print("Recipe is a full DishRecipe, removed base ingredients.")
			print("filtered_ingredients_type_input_dict ", filtered_ingredients_type_input_dict)
			# Since these are IngredientType, not IngredientCategory, we need to convert them
			var input_ingredient_category_dict: Dictionary = {}
			for ingr_type in filtered_ingredients_type_input_dict:
				var ingr_category = Ingredient.convert_type_to_category(ingr_type)
				input_ingredient_category_dict[ingr_category] = input_ingredient_category_dict.get(ingr_category, 0) + 1
			var required_ingr_category_dict: Dictionary = {}
			for ingre_category in recipe.swappable_ingredients:
				required_ingr_category_dict[ingre_category] = required_ingr_category_dict.get(ingre_category, 0) + 1
			# Matching. Same as the above, just for category instead of type
			for ingr_category in required_ingr_category_dict.keys():
				if exact_number_of_ingredients:
					if required_ingr_category_dict[ingr_category] != input_ingredient_category_dict.get(ingr_category, 0):
						output_dish_matched = false
						break
				else:
					if required_ingr_category_dict[ingr_category] > input_ingredient_category_dict.get(ingr_category, 0):
						output_dish_matched = false
						break
			
		if output_dish_matched:
			return recipe

	return null

func match_variant(input_ingredients: Array[Ingredient], recipe: DishRecipe) -> Dish:
	print("match_variant ==================================")
	# Grabbing all the ingredient types from ingredients input
	var input_ingre_type: Array[Ingredient.IngredientType] = []
	for ingredient in input_ingredients:
		input_ingre_type.append(ingredient.ingredient_type)

	# Finding exactly matching recipe based on ingredient types
	for dish in recipe.dishes:
		# Copy the input ingredient's type array. Need to do this for every loop to make it fresh
		var input_ingre_type_copy: Array[Ingredient.IngredientType] = input_ingre_type.duplicate()
		# Create the array of dish's required ingredient type
		var dish_ingredients_type = []
		for ingr in dish.ingredients:
			dish_ingredients_type.append(ingr.ingredient_type)
		# Add base ingredient type of the recipe to required ingredient type
		dish_ingredients_type += recipe.base_ingredients.duplicate()

		input_ingre_type_copy.sort()
		dish_ingredients_type.sort()
		print("dish name ", dish.item_name)
		print("input_ingre_type_copy ", input_ingre_type_copy)
		print("dish_ingredients_type ", dish_ingredients_type)
		if input_ingre_type_copy == dish_ingredients_type:
			return dish.duplicate()

	# No known variant
	# We can have the first variant in list to a generic, technically this line would not be needed,
	# but just incase we set no generic where no extra ingredients needed
	var dish = recipe.dishes[0].duplicate()
	return dish
