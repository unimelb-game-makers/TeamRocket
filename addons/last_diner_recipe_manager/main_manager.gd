@tool
extends Control

signal file_selector(manager)

func _on_food_manager_file_selector(manager: Variant) -> void:
	file_selector.emit(manager)
	
