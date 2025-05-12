class_name CraftingStation
extends Resource

# Equivalent to DCFDishCrafter/Activity Station
@export var recipes: Array[Recipe]
@export var max_ingredients = 1

# Returns either an ingredient output or a food output dependent on recipe
func craft_output(ingredients: Array[Ingredient]) -> Item:
	# First get matching recipe
	var output_recipe: Recipe = match_base_ingredient_types(ingredients, true)
	if output_recipe == null:
		output_recipe = match_base_ingredient_types(ingredients)
	# Process it depending on if it is an ingredient or dish output
	if (output_recipe is IngredientRecipe):
		# If ingredient, just return the output ingredient
		return output_recipe.output_ingredient
	elif (output_recipe is DishRecipe):
		# If output is a dish, then match variants, add effects (based on ingredients) and output final result
		var output_dish = match_variant(ingredients, output_recipe)
		output_dish.ingredients.clear()
		# Adding base and ingredient status effects
		for effect in output_recipe.effects:
			output_dish.effects.append(effect)
		for ingredient in ingredients:
			output_dish.ingredients.append(ingredient)
			for effect in ingredient.effects:
				output_dish.dish_effects.append(effect)
		return output_dish
	return

## We used `exact_number_of_ingredients` to make sure we can search for recipe that use same type of ingredients but
## with different amount. Example: Cut Carrot need 1 Carrot while Carrot Power need 2 Carrot.
func match_base_ingredient_types(ingredients: Array[Ingredient], exact_number_of_ingredients = false) -> Recipe:
	# Grabbing all the ingredient types from ingredients input
	var ingredients_type_input_dict: Dictionary = {}

	# Making Tally of ingredients provided
	for ingredient in ingredients:
		var ingredient_type = ingredient.ingredient_type
		# the .get returns the value in dict or 0 if does not exist
		ingredients_type_input_dict[ingredient_type] = ingredients_type_input_dict.get(ingredient_type, 0) + 1

	# Finding exactly matching recipe based on ingredient types
	for recipe in recipes:
		# Making Tally of ingredients for base recipe
		var recipe_base_ingredient_dict: Dictionary = {}
		for ingredient_type in recipe.base_ingredients:
			recipe_base_ingredient_dict[ingredient_type] = recipe_base_ingredient_dict.get(ingredient_type, 0) + 1

		# Check tally that ingredients enough for base
		var is_enough = false
		for ingredient_type in recipe_base_ingredient_dict.keys():
			if exact_number_of_ingredients:
				# If the base dish required equal for that ingredient than given
				if recipe_base_ingredient_dict[ingredient_type] == ingredients_type_input_dict.get(ingredient_type, 0):
					is_enough = true
					break
			else:
				# If the base dish required less or equal for that ingredient than given
				if recipe_base_ingredient_dict[ingredient_type] <= ingredients_type_input_dict.get(ingredient_type, 0):
					is_enough = true
					break
		if is_enough:
			return recipe
	return null

func match_variant(ingredients: Array[Ingredient], recipe: DishRecipe) -> Dish:
	# Grabbing all the ingredient types from ingredients input
	var ingredients_ingredient_type: Array[Ingredient.IngredientType] = []
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
