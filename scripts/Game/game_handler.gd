extends Node

@export var TIMER = true
@export var TIME_STEP = 8 # How fast the clock ticks per second
@export var START_TIME = 420
@export var MAX_TIME = 1440

@onready var game_timer: Timer = $GameTimer
@onready var canvas: CanvasLayer = $CanvasLayer
@onready var fade_to_black: ColorRect = $CanvasLayer/FadeToBlack


var time
var paused = false


# Load and play bgm, intro goes to loop theme
# Replacement for the buggy AudioInteractiveStream
func load_and_play_main_bgm(intro_pathname:String, loop_pathname: String):
	var music_player_node = $MusicPlayer
	var _on_audio_finished = func():
		$MusicPlayer.stream = load(loop_pathname)
		$MusicPlayer.play()
	if music_player_node:
		music_player_node.stream = load(intro_pathname)
		music_player_node.play()
		music_player_node.connect("finished", _on_audio_finished)


func _ready() -> void:
	canvas.show()
	if TIMER:
		time = START_TIME
		game_timer.wait_time = 1.0 / TIME_STEP
		game_timer.start()
	var tween = create_tween()
	tween.tween_property(fade_to_black, "modulate", Color(0, 0, 0, 0), 1.0)
	var intro_pathname = "res://assets/sfx/team rocket sfx/area themes/kitchen/kitchen_intro.ogg"
	var loop_pathname = "res://assets/sfx/team rocket sfx/area themes/kitchen/kitchen_loop.ogg"
	if $"..".name == "City":
		intro_pathname = "res://assets/sfx/team rocket sfx/area themes/central district/central_district_intro.ogg"
		loop_pathname = "res://assets/sfx/team rocket sfx/area themes/central district/central_district_loop.ogg"
	load_and_play_main_bgm(intro_pathname, loop_pathname)


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
	$MusicPlayer.stop()
	get_tree().change_scene_to_file("res://scenes/environments/Kitchen.tscn")

func load_character_info():
	pass

func _on_player_death() -> void:
	# Restore health and clear inventory
	Globals.player_stats.health = Globals.player_stats.max_health
	InventoryGlobal.clear_inventory(InventoryGlobal.InventoryType.PLAYER)
	switch_to_kitchen()

# Temp Signal so player can return to home easier
func _on_player_channel_complete() -> void:
	Globals.player_stats.health = Globals.player_stats.max_health
	switch_to_kitchen()
