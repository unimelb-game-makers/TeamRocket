extends Node2D
class_name Kitchen

@export var music_theme_day_1: AudioStream
@export var music_theme_day_4: AudioStream
@export var music_theme_day_7: AudioStream
@export var music_theme_day_10: AudioStream

@onready var player: Player = $Player
@onready var interactable_handler: InteractableHandler = $InteractableHandler
@onready var main_theme_player: AudioStreamPlayer = $MainThemePlayer
@onready var minigame_theme_player: AudioStreamPlayer = $MinigameThemePlayer

func _ready() -> void:
	# Link up signal for each interactable
	Globals.kitchen = self
	for interactable in interactable_handler.interactable_holder.get_children():
		if interactable is CookingActivityStation:
			var station = interactable as CookingActivityStation
			station.is_interacting_with.connect(interacting_with_station)
		if interactable is Altar:
			interactable.is_interacting_with.connect(interacting_with_station)

## Controls what how the handlers and players operate when the player is interacting with a CookingActivityStation
func interacting_with_station(is_interacting: bool) -> void:
	if is_interacting:
		player.set_player_movement(false) # Disable player movement
	else:
		player.set_player_movement(true) # Enable player movement


func toggle_music_theme(is_playing_minigame: bool):
	if is_playing_minigame:
		minigame_theme_player.volume_db = 0
		main_theme_player.volume_db = -80
	else:
		minigame_theme_player.volume_db = -80
		main_theme_player.volume_db = 0
