class_name CookingScene extends Control

@onready var activity_game: Control = %Activity
@onready var ingredient_handler: HBoxContainer = %IngredientHandler
@export var activity_res: Activity

signal complete(output)

func _ready() -> void:
	activity_game.complete.connect(finish)
	ingredient_handler.max_slots = activity_res.max_ingredients
	ingredient_handler.create_slots()
	Globals.inventory_ui.toggle_inventory(true)

func start() -> void:
	activity_game.start()
	Globals.inventory_ui.toggle_inventory(false)
	
func add_item(item: Item):
	ingredient_handler.add_item(item)

func finish():
	print("Chop Signal Received")
	complete.emit()
	
