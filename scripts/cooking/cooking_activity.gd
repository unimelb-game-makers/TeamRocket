class_name CookingActivity
extends Control

signal complete(rating: float)

@export var input_ingredients: Array[Ingredient]
@export var output_item: Item

func start(input_ingredients: Array[Ingredient], output_item: Item):
	self.input_ingredients = input_ingredients
	self.output_item = output_item
	
func reset_game():
	pass

func minigame_complete() -> void:
	pass # Implement in child

func finish(rating: float):
	complete.emit(rating)
