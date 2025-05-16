class_name Recipe
extends Resource

# Dish type defines the base effects
@export var effects: Array[Item.Effects]

# Dish Base Ingredients store what ingredient types are *MANDATORY* for the dish
# Dish swappable ingredients store what categories can be swapped out
@export var base_ingredients: Array[Ingredient.IngredientType]
