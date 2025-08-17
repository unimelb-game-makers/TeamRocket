extends Control
class_name RecipeBook

@export var unlocked_recipes: Array[Recipe]

@export var item_button_scene: PackedScene
@export var recipe_button_scene: PackedScene

@export var selected_recipe: Recipe

@onready var recipe_name: Label = $RightPage/RecipeName
@onready var recipe_texture: TextureRect = $RightPage/RecipeTexture
@onready var ingredient_list: GridContainer = $RightPage/IngredientList
@onready var recipe_grid: GridContainer = $LeftPage/RecipeGrid
@onready var crafting_station_name: Label = $RightPage/CraftingStationName
# @onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var sample_ingredients: Dictionary[Ingredient.IngredientType, Item]
@export var sample_ingredients_category: Dictionary[Ingredient.IngredientCategory, Item]

@export var chopping_recipes: Array[Recipe]
@export var pot_recipes: Array[Recipe]
@export var fryer_recipes: Array[Recipe]
@export var oven_recipes: Array[Recipe]
@export var assembly_recipes: Array[Recipe]

@onready var crafting_stations = {
	"Chopping Board": chopping_recipes,
	"Pot": pot_recipes,
	"Fryer": fryer_recipes,
	"Oven": oven_recipes,
	"Preparation": assembly_recipes
}

var open = false

func _ready() -> void:
	Globals.recipe_book = self
	update_selected_recipe()
	update_recipe_book()

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("recipe_book")):
		if not open:
			show()
			open = true
		else:
			hide()
			open = false

func update_recipe_book():
	for recipe in recipe_grid.get_children():
		recipe.queue_free()
	for recipe in unlocked_recipes:
		var recipe_inst = recipe_button_scene.instantiate()
		var recipe_item: Item
		if recipe is IngredientRecipe:
			recipe_item = recipe.output_ingredient
		elif recipe is DishRecipe:
			recipe_item = recipe.dishes[0]
		recipe_inst.item = recipe_item
		recipe_inst.recipe = recipe
		recipe_grid.add_child(recipe_inst)
		recipe_inst.connect("recipe_selected", change_selected_recipe)

func change_selected_recipe(recipe: Recipe):
	selected_recipe = recipe
	update_selected_recipe()

func update_selected_recipe():
	for ingredient in ingredient_list.get_children():
		ingredient.queue_free()
	recipe_name.text = selected_recipe.recipe_name
	if (selected_recipe is DishRecipe):
		recipe_texture.texture = selected_recipe.dishes[0].texture
		for ingredient_category: Ingredient.IngredientCategory in selected_recipe.swappable_ingredients:
			var ingredient_button: ItemInventoryButton = item_button_scene.instantiate()
			ingredient_button.item = sample_ingredients_category[ingredient_category]
			ingredient_list.add_child(ingredient_button)
			ingredient_button.count_label.hide()
			ingredient_button.set_secondary_text(Ingredient.IngredientCategory.keys()[ingredient_category])
		for ingredient_type: Ingredient.IngredientType in selected_recipe.base_ingredients:
			var ingredient_button: ItemInventoryButton = item_button_scene.instantiate()
			ingredient_button.item = sample_ingredients[ingredient_type]
			ingredient_list.add_child(ingredient_button)
			ingredient_button.count_label.hide()
	elif (selected_recipe is IngredientRecipe):
		recipe_texture.texture = selected_recipe.output_ingredient.texture
		for ingredient_type: Ingredient.IngredientType in selected_recipe.base_ingredients:
			var ingredient_button: ItemInventoryButton = item_button_scene.instantiate()
			ingredient_button.item = sample_ingredients[ingredient_type]
			ingredient_list.add_child(ingredient_button)
			ingredient_button.count_label.hide()

	for crafting_station in crafting_stations:
		if selected_recipe in crafting_stations[crafting_station]:
			crafting_station_name.text = crafting_station
			break
