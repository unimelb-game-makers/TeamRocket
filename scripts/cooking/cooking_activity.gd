class_name CookingActivity
extends Control

signal complete(rating: Item.Quality)
signal is_playing_minigame(state: bool)

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
	is_playing_minigame.emit(true)
	Globals.kitchen.toggle_music_theme(true)

func minigame_complete() -> void:
	push_warning("Minigame completed function not implemented in child!!!")

func finish(rating: Item.Quality):
	complete.emit(rating)
	is_playing_minigame.emit(false)
	Globals.kitchen.toggle_music_theme(false)
