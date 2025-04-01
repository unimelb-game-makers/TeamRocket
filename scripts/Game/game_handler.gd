extends Node

@onready var game_timer: Timer = $GameTimer
@onready var fade_to_black: ColorRect = $CanvasLayer/FadeToBlack

var time
var paused = false

@export var TIMER = true

@export var TIME_STEP = 8 # How fast the clock ticks per second
@export var START_TIME = 420
@export var MAX_TIME = 1440

func _ready() -> void:
	$CanvasLayer.show()
	if TIMER:
		time = START_TIME
		game_timer.wait_time = 1.0 / TIME_STEP
		game_timer.start()
	var tween = create_tween()
	tween.tween_property(fade_to_black, "modulate", Color(0, 0, 0, 0), 1.0)
	
func _process(delta: float) -> void:
	pass

func _on_game_timer_timeout() -> void:
	Globals.player_ui.update_time(time)
	time += 1
	if time >= MAX_TIME:
		switch_to_kitchen()
		
func switch_to_kitchen():
	SaveManager.save_game(Globals.chosen_slot_id)
	var tween = create_tween()
	tween.tween_property(fade_to_black, "modulate", Color(0, 0, 0, 2.0), 2.0)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/environments/Kitchen.tscn")

func load_character_info():
	pass

func _on_player_death() -> void:
	switch_to_kitchen()

# Temp Signal so player can return to home easier
func _on_player_channel_complete() -> void:
	switch_to_kitchen()
