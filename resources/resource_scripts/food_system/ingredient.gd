class_name Ingredient
extends Item

# Ingredient class of item used to cook foods

enum IngredientType {
	RAW = 0,
	# Not Edible
	SKEWER = 1,
	SPICE_POWDER = 2,
	# Veges
	POTATO = 100,
	CARROT = 101,
	ONION = 102,
	TOMATO = 103,
	BEAN = 104,
	GARLIC = 105,
	GINGER = 106,
	# Meats
	BEEF = 200,
	PORK = 201,
	FISH = 202,
	CHICKEN = 203,
	# CARBS
	RICE = 300,
	BREAD = 302,
	
	# RAW FOODS
	RAW_POTATO = 401,
	RAW_CARROT = 402,
	RAW_ONION = 403,
	RAW_TOMATO = 404,
	RAW_RICE = 405,
	RAW_GARLIC = 406,
	RAW_GINGER = 407,
}

enum IngredientCategory {
	NONE, INEDIBLE, VEGETABLE, MEAT, FISH, GRAINS, OTHER
}

@export var ingredient_type: IngredientType
@export var ingredient_category: IngredientCategory

# Making something to process effects of the final dish is probably cleaner
# We just keep adding effects of ingredients until dish
# Generic ingredient we evidently leave their effects empty
@export var effects: Array[Item.Effects]

# NOT IMPLEMENTED, could be a list of things to prefix unkown dishes (dishes we did not custom make names for)
@export var name_modifiers: Array[String]

func save() -> Dictionary:
	var item_dict = super ()
	item_dict["item_type"] = ItemType.INGREDIENT
	return item_dict

#static func parse_dict(item_dict: Dictionary) -> Item:
	#var ingredient: Ingredient = load(item_dict["item_id"])
	#return ingredient
