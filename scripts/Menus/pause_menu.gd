extends Control

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("pause")):
		get_tree().paused = !get_tree().paused
		visible = !visible

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")
