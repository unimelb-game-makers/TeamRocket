class_name Food 
extends Item

enum Flavour {SALTY, SWEET, SOUR, BITTER, UMAMI}

@export var food_value: int # Amount of hunger(?) that it will replenish
@export var buffs: Array[String] # Replace this with status system later
@export var food_stats: Dictionary # Salty, Sweet, Sour, Bitter, Umami
