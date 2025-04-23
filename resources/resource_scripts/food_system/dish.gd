class_name Dish
extends Item

# Final output class of item which player can eat or serve

@export var effects: Array[Item.Effects]
@export var ingredients: Array[Ingredient.IngredientType]

func save() -> Dictionary:
	var item_dict = super()
	item_dict["item_type"] = ItemType.DISH
	item_dict["effects"] = effects
	item_dict["ingredients"] = ingredients
	return item_dict
