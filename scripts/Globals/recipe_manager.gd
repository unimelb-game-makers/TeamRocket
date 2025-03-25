extends Node

var all_recipes: Array[Recipe]
var unlocked_recipes: Array[Recipe]
var recipe_ui: Control
var path = "res://resources/recipes/"

func _ready() -> void:
	load_all_recipes()
	
func load_all_recipes() -> void:
	for recipe in DirAccess.open(path).get_files():
		var recipe_loaded = load(path + recipe)
		all_recipes.append(recipe_loaded)

func unlock_recipe(recipe: Recipe):
	unlocked_recipes.append(recipe)
	recipe_ui.recipes = unlocked_recipes
	recipe_ui.load_recipes()
	
func save_recipes() -> Array[String]:
	var output: Array[String] = []
	for recipe in unlocked_recipes:
		output.append(recipe.output_item.item_name)
	return output
	
func load_recipes(saved_recipes: Array) -> void:
	unlocked_recipes = []
	for recipe in saved_recipes:
		for recipe_res in all_recipes:
			if recipe_res.output_item.item_name == recipe:
				unlocked_recipes.append(recipe_res)
				break
	
