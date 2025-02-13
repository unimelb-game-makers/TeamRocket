extends Control

var target_position
@onready var camera_2d: Camera2D = $BackgroundMap/Camera2D
@onready var fade_to_black: ColorRect = $BackgroundMap/FadeToBlack
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var main_menu_buttons: Control = $CanvasLayer/MainMenuButtons
@onready var settings: Control = $CanvasLayer/Settings


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/environments/City.tscn")
	
func _on_settings_pressed() -> void:
	main_menu_buttons.hide()
	settings.show()
	
func _on_settings_back() -> void:
	settings.hide()
	main_menu_buttons.show()

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/Credits.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _ready() -> void:
	reset_camera()

func reset_camera():
	camera_2d.reset_smoothing()
	var random_position = Vector2(randi_range(500, 4500), randi_range(500, 3500))
	camera_2d.position = random_position
	camera_2d.position_smoothing_enabled = true
	camera_2d.position = Vector2(randi_range(500, 4500), randi_range(500, 3500))
	
func _on_camera_timer_timeout() -> void:
	animation_player.play("fade_out_and_in")
