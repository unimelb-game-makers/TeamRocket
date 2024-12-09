class_name CookingScene extends Control

@onready var activity_game: Control = %Activity
@onready var ingredient_handler: HBoxContainer = %IngredientHandler
@onready var start_button: TextureButton = $StartButton

@export var activity_res: Activity

var recipe: Recipe

signal complete(output)

func _ready() -> void:
	activity_game.complete.connect(finish)
	ingredient_handler.max_slots = activity_res.max_ingredients
	ingredient_handler.create_slots()
	Globals.inventory_ui.toggle_inventory(true)
	
func add_item(item: Item):
	ingredient_handler.add_item(item)

func finish():
	complete.emit()
	Inventory_Global.add_item(recipe.output_item, 1)

func _on_start_button_pressed() -> void:
	recipe = activity_res.match_recipe(ingredient_handler.selected_ingredients)
	if (recipe):
		start_button.visible = false
		ingredient_handler.visible = false
		activity_game.visible = true
		activity_game.start()
		Globals.inventory_ui.toggle_inventory(false)
