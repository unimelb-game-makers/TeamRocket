class_name Recipe
extends Resource

@export var required_items: Array[Item]
@export var output_item: Item

# Check if an ingredient is in the recipe
func is_in_recipe(item: Item) -> bool:
	for recipe_item in required_items:
		if recipe_item.is_item(item):
			return true
	return false

# Match recipe to the input (extra ingredients can be added tho)
func match_recipe(input_items: Array[Item]) -> bool:
	var matched_items = []
	var temp_items = input_items.duplicate(true)
	for recipe_item in required_items:
		var found_ingredient = false
		for input_item in temp_items:
			if recipe_item.is_item(input_item):
				matched_items.append(input_item)
				temp_items.erase(input_item)
				found_ingredient = true
				break
		if not found_ingredient:
			break
			
	if len(matched_items) != len(required_items):
		return false
	
	required_items.sort_custom(compare_item_names)
	matched_items.sort_custom(compare_item_names)
	# Sort and compare items between two arrays
	for i in range(len(required_items)):
		if required_items[i] != matched_items[i]:
			return false
	return true

# Compare function for item names to help with match function
func compare_item_names(item1: Item, item2: Item):
	return item1.item_name < item2.item_name
