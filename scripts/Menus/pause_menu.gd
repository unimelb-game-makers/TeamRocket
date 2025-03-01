extends Control

@onready var main_container: Control = $CenterContainer/MainPauseMenu

@onready var sound_settings_container: VBoxContainer = $CenterContainer/SoundSettingsContainer

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("pause")):
		if (get_tree().paused):
			get_tree().paused = false
			hide()
		else:
			get_tree().paused = true
			show()
			main_container.show()
			sound_settings_container.hide()
			$"../Inventory".hide()

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()

func _on_main_menu_pressed() -> void:
	SaveManager.save_game(Globals.chosen_slot_id)
	Globals.reset_save_data()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")

func _on_settings_button_pressed() -> void:
	main_container.hide()
	sound_settings_container.show()

func _on_back_pressed() -> void:
	main_container.show()
	sound_settings_container.hide()
