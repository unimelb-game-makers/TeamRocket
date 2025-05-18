extends Node
class_name GameHandler

@onready var canvas: CanvasLayer = $CanvasLayer
@onready var fade_to_black: ColorRect = $CanvasLayer/FadeToBlack
@onready var music_player: AudioStreamPlayer = $MusicPlayer

@onready var canvas2: CanvasLayer = $CanvasLayer2
@onready var endgame_label: Label = $CanvasLayer2/EndgameUI/Label

var paused = false

func _ready() -> void:
	Globals.game_handler = self
	canvas.visible = true
	canvas2.visible = false
	var tween = create_tween()
	tween.tween_property(fade_to_black, "modulate", Color(0, 0, 0, 0), 1.0)
	var intro_pathname = "res://assets/sfx/team rocket sfx/area themes/kitchen/kitchen_intro.ogg"
	var loop_pathname = "res://assets/sfx/team rocket sfx/area themes/kitchen/kitchen_loop.ogg"
	if $"..".name != "Base" and $"..".name != "Kitchen":
		intro_pathname = "res://assets/sfx/team rocket sfx/area themes/central district/central_district_intro.ogg"
		loop_pathname = "res://assets/sfx/team rocket sfx/area themes/central district/central_district_loop.ogg"
	load_and_play_main_bgm(intro_pathname, loop_pathname)


# Load and play bgm, intro goes to loop theme
# Replacement for the buggy AudioInteractiveStream
func load_and_play_main_bgm(intro_pathname: String, loop_pathname: String):
	var music_player_node = music_player
	var _on_audio_finished = func():
		music_player.stream = load(loop_pathname)
		music_player.play()
	if music_player_node:
		music_player_node.stream = load(intro_pathname)
		music_player_node.play()
		music_player_node.connect("finished", _on_audio_finished)


func switch_to_kitchen():
	SaveManager.save_game(Globals.chosen_slot_id)
	var tween = create_tween()
	tween.tween_property(fade_to_black, "modulate", Color(0, 0, 0, 2.0), 2.0)
	await tween.finished
	music_player.stop()
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


func _on_endgame_title_button_pressed() -> void:
	Globals.reset_save_data()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")


func show_game_over_screen():
	endgame_label.text = "You failed"
	canvas2.visible = true

func show_victory_screen():
	endgame_label.text = "You survived"
	canvas2.visible = true
