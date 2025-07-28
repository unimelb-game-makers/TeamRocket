class_name CookingActivity
extends Control

signal complete(rating: Item.Quality)

@export var input_ingredients: Array[Ingredient]
@export var output_item: Item

var is_initialized: bool = false # Change to true once input and output items have been added

func initialize_activity(inputs: Array[Ingredient], output: Item):
	# Extra validation protection
	if len(inputs) < 1:
		push_error("Initializing activity with no input ingredients!")
		return
	if output == null:
		push_error("Initializing activity with no output ingredient")
		return

	self.input_ingredients = inputs
	self.output_item = output
	is_initialized = true

func minigame_complete() -> void:
	push_warning("Minigame completed function not implemented in child!!!")
	pass # Implement in child

func finish(rating: Item.Quality):
	complete.emit(rating)

#static func create_activity(settings: MinigameSettings) -> CookingActivity:
	#push_error("Needs to be implemented in child!!!")
	#var ins: CookingActivity = load("res://scenes/cooking/activities/ChoppingActivity.tscn").instantiate()
	#return ins
