extends Node

@onready var game_timer: Timer = $GameTimer

var time
var paused = false

@export var TIME_STEP = 2 # How fast the clock ticks per second
@export var START_TIME = 420
@export var MAX_TIME = 1440

func _ready() -> void:
	time = START_TIME
	game_timer.wait_time = 1.0 / TIME_STEP
	game_timer.start()
	
func _process(delta: float) -> void:
	pass

func _on_game_timer_timeout() -> void:
	Globals.player_ui.update_time(time)
	time += 1
	if time >= MAX_TIME:
		switch_to_kitchen()
		
func switch_to_kitchen():
	get_tree().change_scene_to_file("res://scenes/environments/Kitchen.tscn")

func load_character_info():
	pass

func _on_player_death() -> void:
	switch_to_kitchen()
