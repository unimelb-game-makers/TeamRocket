extends Control
signal back

func _on_button_pressed() -> void:
	back.emit()


func _on_back_button_pressed() -> void:
	Globals.reset_save_data()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")

func play_button_hover_sfx():
	SoundManager.play_button_hover_sfx()