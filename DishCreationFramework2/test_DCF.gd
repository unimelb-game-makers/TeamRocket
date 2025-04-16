extends Node

@export var ingredients: Array[DCF_Ingredient]

@onready var pork: DCF_Ingredient = load("res://DishCreationFramework2/TEST_RESOURCES/cool_pork.tres")
@onready var skewer: DCF_Ingredient = load("res://DishCreationFramework2/TEST_RESOURCES/crispy_skewer.tres")
@onready var onion: DCF_Ingredient = load("res://DishCreationFramework2/TEST_RESOURCES/crappy_onion.tres")
@onready var special_porky: DCF_Ingredient = load("res://DishCreationFramework2/TEST_RESOURCES/special_porky.tres")

@onready var dish_crafter: DCF_DishCrafter = $DishCrafter
@onready var ingredient_crafter: DCF_IngredientCrafter = $IngredientCrafter

func _ready() -> void:
	# No ingredients
	
	var dish: DCF_Dish = dish_crafter.craft_dish(ingredients)
	
	if dish != null:
		print(dish.item_name)
		print(dish.dish_effects)
	else:
		print("NO DISH")
		
	# Just enough for base pizza
	ingredients.append(onion.duplicate())
	ingredients.append(pork.duplicate())
	ingredients.append(skewer.duplicate())

	var dish2 = dish_crafter.craft_dish(ingredients)
	if dish2 != null:
		print(dish2.item_name)
		print(dish2.dish_effects)
	else:
		print("NO DISH")
	
	# Exactly for cheesy pizza
	ingredients.append(skewer.duplicate())
	ingredients.append(skewer.duplicate())
	var dish3 = dish_crafter.craft_dish(ingredients)
	if dish3 != null:
		print(dish3.item_name)
		print(dish3.dish_effects)
	else:
		print("NO DISH")
	
	# More than enough for base pizza but not exact for cheesy, more in fact
	ingredients.append(pork.duplicate())
	ingredients.append(pork.duplicate())
	var dish4 = dish_crafter.craft_dish(ingredients)
	if dish4 != null:
		print(dish4.item_name)
		print(dish4.dish_effects)
	else:
		print("NO DISH")
	
	ingredients.clear()
	
	# CRAFTING ingredient see if it fails
	var fail_ing = ingredient_crafter.craft_ingredient(ingredients)
	if fail_ing != null:
		print(fail_ing.item_name)
		print(fail_ing.effects)
	else:
		print("NO Ingredient")
	
	# Crafting exactly a super skewer
	ingredients.append(special_porky.duplicate())
	ingredients.append(onion.duplicate())
	var special_skewer = ingredient_crafter.craft_ingredient(ingredients)
	if special_skewer != null:
		print(special_skewer.item_name)
		print(special_skewer.effects)
	else:
		print("NO Ingredient")
		
	ingredients.clear()
	# MAking cheesy pizza with all buffs
	ingredients.append(special_skewer)
	ingredients.append(onion.duplicate())
	ingredients.append(pork.duplicate())
	ingredients.append(skewer.duplicate())
	ingredients.append(skewer.duplicate())
	var super_cheesy_pizza = dish_crafter.craft_dish(ingredients)
	if super_cheesy_pizza != null:
		print(super_cheesy_pizza.item_name)
		print(super_cheesy_pizza.dish_effects)
	else:
		print("NO DISH")
	
	
