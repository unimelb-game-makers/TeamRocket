extends Node

@export var ingredients: Array[DCF_Ingredient]

@onready var pork: DCF_Ingredient = load("res://DishCreationFramework2/TEST_RESOURCES/cool_pork.tres")
@onready var skewer: DCF_Ingredient = load("res://DishCreationFramework2/TEST_RESOURCES/crispy_skewer.tres")
@onready var onion: DCF_Ingredient = load("res://DishCreationFramework2/TEST_RESOURCES/crappy_onion.tres")
@onready var special_porky: DCF_Ingredient = load("res://DishCreationFramework2/TEST_RESOURCES/special_porky.tres")

@onready var dish_crafter: DCF_DishCrafter = $DishCrafter

func _ready() -> void:
	# Making Cheese pizza
	ingredients.append(onion.duplicate())
	ingredients.append(pork.duplicate())
	ingredients.append(skewer.duplicate())
	ingredients.append(skewer.duplicate())
	ingredients.append(skewer.duplicate())
	
	var dish3 = dish_crafter.craft_dish(ingredients)
	if dish3 != null:
		print(dish3.item_name)
		print(dish3.dish_effects)
	else:
		print("NO DISH")
		
	print("==================")
	var dish_as_dictionary = DCF_Dish.save(dish3)
	print(dish_as_dictionary)
	
	var loaded_dish = DCF_Dish.instantiate(dish_as_dictionary)
	print(loaded_dish)
