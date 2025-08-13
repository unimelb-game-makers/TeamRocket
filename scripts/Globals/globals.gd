extends Node

@export var default_player_stats: PlayerStatsResource
@export var requested_dish_list: Array[Dish]
## Check Enemy.EnemyEnumId for order
@export var enemy_scene_database: Array[PackedScene]

signal devotion_changed(value: int)

var player: Player
var player_stats: PlayerStatsResource

var kitchen: Kitchen

var item_handler: ItemHandler
var enemy_handler: EnemyHandler
var interactable_handler: InteractableHandler
var game_handler: GameHandler
var map_generator: MapGenerator

var main_ui: MainUI
var inventory_ui: InventoryUI
var player_ui: PlayerUI

var chosen_slot_id = -1 # For saving
var start_record_timestamp = 0
var total_playtime = 0

# Devotion stuff
const STARTING_DEVOTION = 30
const FAILED_DEVOTION_PENALTY = 10
const PASSED_DEVOTION_BONUS = 15
var devotion: int = STARTING_DEVOTION:
	set(value):
		devotion = value
		devotion_changed.emit(value)
var current_requested_dish_idx = 0 # aka progress counter
var current_day: int = 1

var is_game_ended = false
var dont_save_game = false

# Map generation data stuff
var spawn_unique_pois: Array[PlaceablePOI.UniquePoiEnum] = []

# Setting parameters here
const FPS_LIMIT_ARRAY = [30, 60, 120, 144, 240, 0]
const RESOLUTION_ARRAY = [
	Vector2i(2560, 1440), Vector2i(1920, 1080), Vector2i(1440, 900),
	Vector2i(1366, 768), Vector2i(1280, 720), Vector2i(1024, 768)
]
var master_volume: float = 1
var effects_volume: float = 1
var music_volume: float = 1
var ui_volume: float = 1
var fps_limit_index: int = 2 # Refer to EnumAutoload.FPS_LIMIT_ARRAY
var resolution_index: int = 1 # Refer to EnumAutoload.RESOLUTION_ARRAY. Not used in FULL_SCREEN
var vsync_option_index: int = 1 # From 0 to 2 for DISABLED / ENABLED / ADAPTIVE
var window_mode_index: int = 1 # From 0 to 2 for FULLSCREEN / WINDOWED / BORDERLESS WINDOWED

func _ready() -> void:
	player_stats = default_player_stats
	SaveManager.load_setting_config()

func reset_save_data():
	start_record_timestamp = 0
	total_playtime = 0
	is_game_ended = false
	dont_save_game = false
	InventoryGlobal.reset_save_data()

func start_record_playtime():
	start_record_timestamp = Time.get_ticks_msec()

func update_total_playtime():
	var played_time = Time.get_ticks_msec() - start_record_timestamp
	total_playtime += played_time
	start_record_timestamp = Time.get_ticks_msec() # Reset start timestamp


func gameover():
	print("Gameover")
	dont_save_game = true
	player.set_player_movement(false)
	game_handler.show_game_over_screen()
	return

func victory():
	print("Victory")
	player.set_player_movement(false)
	game_handler.show_victory_screen()
	return

func check_game_end_condition() -> bool:
	if current_requested_dish_idx > requested_dish_list.size() - 1:
		victory()
		return true

	if devotion <= 0:
		gameover()
		return true

	return false
