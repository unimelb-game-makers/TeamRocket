class_name CookingScene extends Control

@onready var ingredient_handler: IngredientHandler = %IngredientHandler
@onready var start_button: TextureButton = $Background/ChosenFoodArea/StartButton
@onready var inventory_container: Container = $Background/InventoryArea/InventoryContainer
@onready var activity: Control = $Activity
@onready var selected_food_list: Container = $Background/ChosenFoodArea/SelectedFoodList
@onready var activity_animated_sprite: TextureRect = $Background/ChosenFoodArea/ActivityAnimatedSprite
@onready var activity_label: Label = $Background/ChosenFoodArea/ActivityLabel

@onready var inventory_area: Control = $Background/InventoryArea
@onready var chosen_food_area: Control = $Background/ChosenFoodArea

@export var activity_name: String
@export var activity_animated_texture: AnimatedTexture
@export var activity_res: Activity
@export var activity_scene: PackedScene

var recipe: Recipe
var activity_is_in_progress = false

signal complete(output)

func _ready() -> void:
	activity.complete.connect(finish)
	reset()
	activity_label.text = activity_name
	if activity_animated_texture:
		activity_animated_sprite.texture = activity_animated_texture

func reset():
	ingredient_handler.max_slots = activity_res.max_ingredients
	ingredient_handler.update_slots()
	inventory_container.update_inventory_list()
	activity.reset_game()

	start_button.visible = true
	ingredient_handler.visible = true
	inventory_container.visible = true
	selected_food_list.visible = true
	activity.visible = false
	
	inventory_area.visible = true
	chosen_food_area.visible = true

func add_item(item: Ingredient, _amount: int):
	ingredient_handler.add_item(item)

func finish():
	activity_is_in_progress = false
	
	var output_item = recipe.generate_item(ingredient_handler.selected_ingredients)
	complete.emit(output_item)
	InventoryGlobal.add_item(output_item, 1)
	ingredient_handler.clear_slots()
	reset()

func _on_start_button_pressed() -> void:
	recipe = activity_res.match_recipe(ingredient_handler.selected_ingredients)
	if (recipe):
		start_button.visible = false
		ingredient_handler.visible = false
		activity.visible = true
		selected_food_list.visible = false
		inventory_container.visible = false
		
		inventory_area.visible = false
		chosen_food_area.visible = false
		
		activity_is_in_progress = true
		activity.start(ingredient_handler.selected_ingredients, recipe.generate_item(ingredient_handler.selected_ingredients))

func _on_ingredient_handler_update_list() -> void:
	inventory_container.update_inventory_list()

func _on_inventory_container_item_select(item: Ingredient, amount: Variant) -> void:
	add_item(item, amount)
