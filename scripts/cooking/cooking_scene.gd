class_name CookingScene extends Control

@onready var ingredient_handler: IngredientHandler = %IngredientHandler
@onready var start_button: TextureButton = $Background/ChosenFoodArea/StartButton
@onready var inventory_select_list: Container = $Background/InventoryArea/InventorySelectList
@onready var activity: Control = $Activity
@onready var selected_food_list: Container = $Background/ChosenFoodArea/SelectedFoodList

@export var activity_res: Activity
@export var activity_scene: PackedScene

var recipe: Recipe
var activity_is_in_progress = false

signal complete(output)

func _ready() -> void:
	activity.complete.connect(finish)
	reset()

func reset():
	ingredient_handler.max_slots = activity_res.max_ingredients
	ingredient_handler.update_slots()
	inventory_select_list.update_inventory_list()
	activity.reset_game()

	start_button.visible = true
	ingredient_handler.visible = true
	inventory_select_list.visible = true
	selected_food_list.visible = true
	activity.visible = false


func add_item(item: Item, _amount: int):
	ingredient_handler.add_item(item)

func finish():
	activity_is_in_progress = false
	complete.emit(recipe.output_item)
	InventoryGlobal.add_item(recipe.output_item, 1)
	ingredient_handler.clear_slots()
	reset()

func _on_start_button_pressed() -> void:
	recipe = activity_res.match_recipe(ingredient_handler.selected_ingredients)
	if (recipe):
		start_button.visible = false
		ingredient_handler.visible = false
		activity.visible = true
		selected_food_list.visible = false
		inventory_select_list.visible = false
		activity_is_in_progress = true
		activity.start()

func _on_ingredient_handler_update_list() -> void:
	inventory_select_list.update_inventory_list()
