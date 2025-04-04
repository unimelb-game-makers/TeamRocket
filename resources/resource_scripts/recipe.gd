class_name Recipe
extends Resource

@export var base_recipe_items: Array[Ingredient]
@export var base_output_item: Item
@export var swappable_ingredient_types: Dictionary[Ingredient.IngredientType, int]

func generate_item(input_items: Array[Ingredient]):
	var input_items_copy = input_items.duplicate()
	# Check if base recipe matches
	if not match_base_recipe(input_items):
		return
		
	# Remove base recipe items from input
	for base_item in base_recipe_items:
		for item in input_items_copy:
			if base_item.item_name == item.item_name:
				input_items_copy.erase(item)
				break
	
	# Check swappable ingredients match
	var to_be_filled_ingredients = swappable_ingredient_types.duplicate()
	for ingredient in input_items_copy:
		if ingredient.ingredient_type in to_be_filled_ingredients.keys():
			to_be_filled_ingredients[ingredient.ingredient_type] -= 1
	
	for ingredient_type in to_be_filled_ingredients:
		if to_be_filled_ingredients[ingredient_type] > 0:
			return

	# Generate food using swappable ingredients
	if (base_output_item is Food):
		var output_food: Item = base_output_item.duplicate()
		var base_name = output_food.item_name
		if (input_items_copy.size() > 0):
			base_name += " with "
		for ingredient in input_items_copy:
			# Add status effects
			# Name Generation Scheme?
			# Base Food + with + Ingredient 1 + , +  Ingredient 2 + and + Ingredient 3
			output_food.player_status_effects.append(ingredient.player_status_effects)
			output_food.gun_status_effects.append(ingredient.gun_status_effects)
			base_name += ingredient.item_name + ", "
		
		output_food.item_name = base_name
		return output_food
	else:
		return base_output_item
	
func match_base_recipe(input_items) -> bool:
	# Note to others: Do not have duplicate ingredients in base recipe
	for base_item in base_recipe_items:
		var item_found = false
		for item in input_items:
			if base_item.item_name == item.item_name:
				item_found = true
		if not item_found:
			return false
	return true
	

## Check if an ingredient is in the recipe
#func is_in_recipe(item: Item) -> bool:
	#for recipe_item in required_items:
		#if recipe_item.is_item(item):
			#return true
	#return false
#
## Match recipe to the input (extra ingredients can be added tho)
#func match_recipe(input_items: Array[Item]) -> bool:
	#var matched_items = []
	#var temp_items = input_items.duplicate(true)
	#for recipe_item in required_items:
		#var found_ingredient = false
		#for input_item in temp_items:
			#if recipe_item.is_item(input_item):
				#matched_items.append(input_item)
				#temp_items.erase(input_item)
				#found_ingredient = true
				#break
		#if not found_ingredient:
			#break
			#
	#if len(matched_items) != len(required_items):
		#return false
	#
	#required_items.sort_custom(compare_item_names)
	#matched_items.sort_custom(compare_item_names)
	## Sort and compare items between two arrays
	#for i in range(len(required_items)):
		#if required_items[i] != matched_items[i]:
			#return false
	#return true

# Compare function for item names to help with match function
func compare_item_names(item1: Item, item2: Item):
	return item1.item_name < item2.item_name
