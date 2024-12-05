class_name CookingScene extends Control

@onready var activity_game: Control = %Activity
@onready var ingredient_handler: HBoxContainer = %IngredientHandler
@export var activity_res: Activity

signal complete(output)

func _ready() -> void:
	activity_game.complete.connect(finish)
	ingredient_handler.max_slots = activity_res.max_ingredients
	ingredient_handler.create_slots()

func start() -> void:
	activity_game.start()
	
func finish():
	print("Chop Signal Received")
	complete.emit()
