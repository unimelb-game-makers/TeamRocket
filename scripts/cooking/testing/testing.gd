extends Node

@export var resource_type: Item

func _ready() -> void:
	var path = "res://resources/cooking/ingredients/carrot.tres"
	var load_type = load("res://resources/cooking/ingredients/carrot.tres")
	var load_type2 = load("res://resources/cooking/ingredients/carrot.tres")
	var duplicate_type = load_type.duplicate()
	
	print("Resource Way: ", resource_type.get_instance_id())
	print("Load Way Attemp 1: ", load_type.get_instance_id())
	print("Load Way Attemp 2: ", load_type2.get_instance_id())
	print("Duplicate Way: ", duplicate_type.get_instance_id())
