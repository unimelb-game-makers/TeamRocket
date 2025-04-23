extends Node

@export var workbench: Array[Ingredient]

@onready var crafting_station: CraftingStation = $CraftingStation

func _ready() -> void:
	print(crafting_station.craft_output(workbench).save())
