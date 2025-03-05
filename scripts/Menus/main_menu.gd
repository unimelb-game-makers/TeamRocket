extends Control
class_name MainMenu

var target_position
@onready var camera_2d: Camera2D = $BackgroundMap/Camera2D
@onready var fade_to_black: ColorRect = $BackgroundMap/FadeToBlack
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var main_menu_buttons: Control = $CanvasLayer/MainMenuButtons
@onready var setting_menu: Control = $CanvasLayer/SettingMenu
@onready var save_ui = $CanvasLayer/SaveUI

func _ready() -> void:
	reset_camera()
	save_ui.visible = false

func _on_play_button_pressed() -> void:
	save_ui.visible = true
	main_menu_buttons.hide()

func start_game():
	get_tree().change_scene_to_file("res://scenes/environments/City.tscn")
	SaveManager.load_game(Globals.chosen_slot_id)
	Globals.start_record_playtime()
	
func _on_settings_pressed() -> void:
	main_menu_buttons.hide()
	setting_menu.show()
	
func _on_settings_back() -> void:
	setting_menu.hide()
	main_menu_buttons.show()

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/Credits.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()


func reset_camera():
	camera_2d.reset_smoothing()
	var random_position = Vector2(randi_range(500, 4500), randi_range(500, 3500))
	camera_2d.position = random_position
	camera_2d.position_smoothing_enabled = true
	camera_2d.position = Vector2(randi_range(500, 4500), randi_range(500, 3500))
	
func _on_camera_timer_timeout() -> void:
	animation_player.play("fade_out_and_in")

func play_button_hover_sfx():
	SoundManager.play_button_hover_sfx()


func _on_save_ui_back_button_pressed() -> void:
	main_menu_buttons.show()
	save_ui.visible = false
