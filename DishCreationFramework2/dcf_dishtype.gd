class_name DCF_DishType
extends Resource

# Dish type defines the base effects
@export var dishtype_effects: Array[String]

# Dish base ingredients simply stores the types of what is needed to make this dish
@export var base_ingredients: Array[DCF_Ingredient.IngredientType]

# All Dishes of this type
@export var dishes: Array[DCF_Dish]
