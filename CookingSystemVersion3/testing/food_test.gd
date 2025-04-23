extends Node

@export var workbench: Array[Ingredient]
@export var crafting_station: CraftingStation

func _ready() -> void:
	print(crafting_station.craft_output(workbench).save())
