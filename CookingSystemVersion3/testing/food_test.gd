extends Node

@export var workbench: Array[Ingredient]
@export var crafting_station: CraftingStation

func _ready() -> void:
	var output = crafting_station.craft_output(workbench)
	print(output.save())
	print(Item.load(output.save()).save())
