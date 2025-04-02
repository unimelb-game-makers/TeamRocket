extends Control

@onready var main_container: Control = $MainPauseMenu
@onready var setting_menu: SettingMenu = $SettingMenu

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("pause")):
		if (get_tree().paused):
			get_tree().paused = false
			hide()
		else:
			get_tree().paused = true
			show()
			main_container.show()
			setting_menu.hide()
			Globals.inventory_ui.toggle_inventory(false)

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()


func _on_main_menu_button_pressed() -> void:
	SaveManager.save_game(Globals.chosen_slot_id)
	Globals.reset_save_data()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")

func _on_settings_button_pressed() -> void:
	main_container.hide()
	setting_menu.show()

func _on_setting_menu_back() -> void:
	main_container.show()
	setting_menu.hide()

func play_button_hover_sfx():
	SoundManager.play_button_hover_sfx()
