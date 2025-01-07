extends Node

var time
var paused = false

@export var TIME_STEP = 8
@export var START_TIME = 420
@export var MAX_TIME = 1440

func _ready() -> void:
	time = START_TIME
	
func _process(delta: float) -> void:
	pass

func _on_game_timer_timeout() -> void:
	Globals.player_ui.update_time(time)
	time += TIME_STEP
	if time >= MAX_TIME:
		print("Time out")
		switch_to_kitchen()
		
func switch_to_kitchen():
	get_tree().change_scene_to_file("res://scenes/environments/Kitchen.tscn")

func load_character_info():
	pass
