extends Button

var recipe: Recipe
signal recipe_selected(recipe)
	
func update_icon():
	icon = recipe.output_item.texture

func _on_pressed() -> void:
	recipe_selected.emit(recipe)
