extends Control

func _on_play_button_pressed() -> void:
	print("Test")
	get_tree().change_scene_to_file("res://scenes/environments/City.tscn")
	
func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/Settings.tscn")

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/Credits.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
