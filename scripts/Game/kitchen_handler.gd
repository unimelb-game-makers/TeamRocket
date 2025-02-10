extends Node

var sacrificed = false

func _on_exit_area_body_entered(body: Node2D) -> void:
	switch_to_city()
	
func switch_to_city():
	get_tree().change_scene_to_file("res://scenes/environments/City.tscn")

func sacrifice():
	pass
