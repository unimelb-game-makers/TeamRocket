extends Area2D

@export var recipe: Recipe

func interact() -> void:
	RecipeManager.unlock_recipe(recipe)
	queue_free()
