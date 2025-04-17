class_name DCF_Dish
extends DCF_Item

# Dish defines some extra effects
@export var dish_effects: Array[DCF_Item.Effects]
@export var ingredients: Array[DCF_Ingredient.IngredientType]

const dish_dir_path = "res://DishCreationFramework2/TEST_RESOURCES/"
const dish_texture_dir_path = "res://DishCreationFramework2/TEST_SAVE_DIR/"

static func save(dish: DCF_Dish) -> Dictionary:
	var dish_as_dict = {}
	dish_as_dict["dish_id"] = dish.item_id
	dish_as_dict["dish_name"] = dish.item_name
	dish_as_dict["texture_id"] = dish.texture_id
	# I am assuming the description is not gonna change
	#dish_as_dict["description"]
	#dish_as_dict["weight"]
	#dish_as_dict["rarity"]
	var effects: Array[DCF_Item.Effects] = []
	for effect in dish.dish_effects:
		effects.append(effect)
	dish_as_dict["effects"] = effects
	
	return dish_as_dict
	
static func instantiate(dish_as_dict: Dictionary) -> DCF_Dish:
	# I am currently assuming dish_id is the same name as it is in the file system
	# A helper global function which gets file name from item_id can be considered
	# I will be using an example one here
	var dish_name_path = ""
	match dish_as_dict["dish_id"]:
		DCF_Item.ItemId.CHEESE_PIZZA:
			dish_name_path = "cheesy_pizza.tres"
		DCF_Item.ItemId.TOPPINGLESS_PIZZA:
			dish_name_path = "toppingless_pizza.tres"
		_:
			dish_name_path = "unknown.tres"
		
	
	var dish_resource_path = dish_dir_path + dish_name_path
	var dish_resource = load(dish_resource_path)
	var dish: DCF_Dish = dish_resource.duplicate()
	
	# While a dish name is unlikely to change
	# This is in prediction that we may custom make names from specific ingredients
	dish.item_name = dish_as_dict["dish_name"]
	
	# It is easier to just wipe the dish default effects and reinsert
	dish.dish_effects.clear()
	for effect in dish_as_dict["effects"]:
		dish.dish_effects.append(effect)
	
	# Same assumption as for dish resource path
	# But storing texture may not be needed if we are keeping the texture
	# the same for a dish regardless
	var dish_texture_path = dish_texture_dir_path + str(dish_as_dict["texture_id"])
	dish.texture = load(dish_texture_path)
	
	return dish

func _to_string() -> String:
	return self.item_name + " with effects " + str(self.dish_effects)
