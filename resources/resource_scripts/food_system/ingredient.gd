class_name Ingredient
extends Item

# Ingredient class of item used to cook foods

enum IngredientType {
	# Not Edible
	SKEWER = 1,
	SPICE_POWDER = 2,
	# Veges
	POTATO = 100,
	CARROT = 101,
	ONION = 102,
	TOMATO = 103,
	# Meats
	BEEF = 200,
	PORK = 201,
	FISH = 202,
	CHICKEN = 203,
}

enum IngredientCategory {
	NONE, INEDIBLE, VEGETABLE, MEAT, FISH, BREAD, OTHER
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
	var item_dict = super()
	item_dict["item_type"] = ItemType.INGREDIENT
	item_dict["ingredient_type"] = ingredient_type
	item_dict["ingredient_category"] = ingredient_category
	item_dict["effects"] = effects
	
	return item_dict

static func parse_dict(item_dict: Dictionary) -> Item:
	var ingredient: Ingredient = Ingredient.new()
	ingredient.item_name = item_dict["item_name"]
	print(ingredient.item_name)
	ingredient.texture_id = item_dict["texture_id"]
	ingredient.description = item_dict["description"]
	ingredient.weight = item_dict["weight"]
	ingredient.rarity = item_dict["rarity"]
	#
	#ingredient.effects = item_dict["effects"]
	ingredient.ingredient_type = item_dict["ingredient_type"]
	ingredient.ingredient_category = item_dict["ingredient_category"]
	return ingredient
