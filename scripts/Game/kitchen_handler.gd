extends Node

func _on_exit_area_body_entered(body: Node2D) -> void:
	switch_to_city()
	
func switch_to_city():
	print("Switching")
	get_tree().change_scene_to_file("res://scenes/environments/City.tscn")
