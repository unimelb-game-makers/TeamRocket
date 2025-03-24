extends Panel

@export var ingredient_button_scene: PackedScene

@onready var recipe_title: Label = $RecipeTitle

@onready var food_frame_texture: TextureRect = $FoodFrame/FoodFrameTexture
@onready var cooking_station_texture: TextureRect = $CookingStationFrame/CookingStationTexture

@onready var difficulty_frame: Panel = $DifficultyFrame
@onready var ingredients_grid_container: GridContainer = $IngredientsPanel/IngredientsGridContainer

func select_recipe(recipe: Recipe):
	var item: Item = recipe.output_item
	recipe_title.text = item.item_name
	food_frame_texture.texture = item.texture
	#cooking_station_texture.texture = recipe
	list_ingredients(recipe)
	
func list_ingredients(recipe: Recipe):
	for child in ingredients_grid_container.get_children():
		child.queue_free()
	for item in recipe.required_items:
		var ingredient_button = ingredient_button_scene.instantiate()
		ingredients_grid_container.add_child(ingredient_button)
		ingredient_button.item = item
		ingredient_button.update_icon()
