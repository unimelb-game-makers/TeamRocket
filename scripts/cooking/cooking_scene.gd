class_name CookingScene extends Control

@onready var ingredient_handler: HBoxContainer = %IngredientHandler
@onready var start_button: TextureButton = $StartButton
@onready var inventory_select_list: CenterContainer = $InventorySelectList
@onready var activity: Control = $Activity
@onready var selected_food_list: CenterContainer = $SelectedFoodList

@export var activity_res: Activity

var recipe: Recipe

signal complete(output)

func reset():
	ingredient_handler.max_slots = activity_res.max_ingredients
	ingredient_handler.create_slots()
	inventory_select_list.update_inventory_list()
	activity.reset_game()
	
	start_button.visible = true
	ingredient_handler.visible = true
	inventory_select_list.visible = true
	selected_food_list.visible = true
	activity.visible = false

func _ready() -> void:
	activity.complete.connect(finish)
	reset()
	
func add_item(item: Item, amount: int):
	ingredient_handler.add_item(item)

func finish():
	complete.emit(recipe.output_item)
	Inventory_Global.add_item(recipe.output_item, 1)
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
		activity.start()

func _on_ingredient_handler_update_list() -> void:
	inventory_select_list.update_inventory_list()
