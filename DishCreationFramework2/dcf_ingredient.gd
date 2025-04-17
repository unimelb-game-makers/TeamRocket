class_name DCF_Ingredient
extends DCF_Item

enum IngredientType {
	# Not Edible
	SKEWER = 10,
	# Veges
	POTATO = 100,
	CARROT = 101,
	ONION = 102,
	TOMATO = 103,
	# Meats
	BEEF = 200,
	PORK = 201,
	FISH = 202
}

@export var ingredient_type: IngredientType

# Making something to process effects of the final dish is probably cleaner
# We just keep adding effects of ingredients until dish
# Generic ingredient we evidently leave their effects empty
@export var effects: Array[DCF_Item.Effects]

# NOT IMPLEMENTED, could be a list of things to prefix unkown dishes (dishes we did not custom make names for)
@export var name_modifiers: Array[String]
