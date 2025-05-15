class_name CookingActivity
extends Control

signal complete(output)

var input_ingredients: Array[Ingredient]
var output_item: Item

func start(input_ingredients: Array[Ingredient], output_item: Item):
	self.input_ingredients = input_ingredients
	self.output_item = output_item
	
func reset_game():
	pass

func finish():
	complete.emit()
