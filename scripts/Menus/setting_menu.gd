extends Control
class_name SettingMenu


@onready var tab_container: TabContainer = $BG/TabContainer

signal back


func _on_back_button_pressed() -> void:
	back.emit()


func _on_game_tab_button_pressed() -> void:
	SoundManager.play_button_click_sfx()
	tab_container.current_tab = 0

func _on_display_tab_button_pressed() -> void:
	SoundManager.play_button_click_sfx()
	tab_container.current_tab = 1

func _on_audio_tab_button_pressed() -> void:
	SoundManager.play_button_click_sfx()
	tab_container.current_tab = 2

func play_hover_sfx():
	SoundManager.play_button_hover_sfx()
