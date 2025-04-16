class_name DCF_DishCrafter
extends Node

# THE DIFFEERENCE BETWEEN CRAFTING INGREDIENTS AND DISHES
# IS THAT DISHES WILL BE CREATED AS LONG AS
# YOU HAVE THE BASE, BUT MATCHING A PRE BUILT DISH IS BETTER

# If there is a method to just get all from a file
# where we store everything even better
@export var all_dish_types: Array[DCF_DishType]

func craft_dish(ingredients: Array[DCF_Ingredient]) -> DCF_Dish:
	var dish_type: DCF_DishType = match_base_ingredient_types(ingredients)
	if dish_type != null:
		# Check if there is a known variant
		var dish_variant: DCF_Dish = match_variant_ingredient_types(ingredients, dish_type)
		
		# THE IMPORTANT PART OF THE CRAFTING - influence result with inputs
		# Attach Buffs | note: dish variant intrinsic buffs are already inside
		for ingredient in ingredients:
			for effect in ingredient.effects:
				dish_variant.dish_effects.append(effect)
				
		for effect in dish_type.dishtype_effects:
			dish_variant.dish_effects.append(effect)
			
		# TODO: Modify Name and Sprite based on...
		return dish_variant
		
	else:
		print("Failed to craft dish!")
		return null
		
func match_base_ingredient_types(ingredients: Array[DCF_Ingredient]) -> DCF_DishType:
	# Grabbing all the ingredient types from ingredients input
	var ingredients_type: Dictionary = {}

	# Making Tally of ingredients provided
	for ingredient in ingredients:
		var i = ingredient.ingredient_type
		ingredients_type[i] = ingredients_type.get(i, 0) + 1 # the .get returns the value in dict or 0 if does not exist
	
	# Finding exactly matching recipe based on ingredient types
	for dish_type in all_dish_types:
		# Making Tally of ingredients for base recipe
		var dish_type_ingredients: Dictionary = {}
		for ingredient_type in dish_type.base_ingredients:
			var j = ingredient_type
			dish_type_ingredients[j] = dish_type_ingredients.get(j, 0) + 1 # the .get returns the value in dict or 0 if does not exist
		
		# Check tally that ingredients enough for base
		var is_enough = true
		for ingredient_type in dish_type_ingredients.keys():
			if dish_type_ingredients[ingredient_type] > ingredients_type.get(ingredient_type, 0): # If the base dish requirees more for that ingredient than given
				is_enough = false
				break
		if is_enough:
				return dish_type
	return null

func match_variant_ingredient_types(ingredients: Array[DCF_Ingredient], dish_type: DCF_DishType) -> DCF_Dish:
	# Grabbing all the ingredient types from ingredients input
	var ingredients_ingredient_type: Array[DCF_Ingredient.IngredientType] = []
	for ingredient in ingredients:
		ingredients_ingredient_type.append(ingredient.ingredient_type)
	
	# Finding exactly matching recipe based on ingredient types
	for dish in dish_type.dishes:
		var ingredients_type_copy = ingredients_ingredient_type.duplicate()
		var dish_copy = dish.ingredients.duplicate()
		dish_copy += dish_type.base_ingredients.duplicate()
		ingredients_type_copy.sort()
		dish_copy.sort()
		if ingredients_type_copy == dish_copy:
			return dish.duplicate()
	
	# No known variant
	# We can have the first variant in list to a generic, technically this line would not be needed,  
	# but just incase we set no generic where no extra ingredients needed
	var dish = dish_type.dishes[0].duplicate()
	return dish
