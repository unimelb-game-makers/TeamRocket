extends Node

@export var default_player_stats: PlayerStatsResource

var player: Player
var player_stats: PlayerStatsResource
var item_handler
var map

var main_ui: MainUI
var inventory_ui: InventoryUI
var player_ui: PlayerUI
var enemy_handler

var chosen_slot_id = -1 # For saving
var start_record_timestamp = 0
var total_playtime = 0

var player_level = 1

var item_database: Array[Item]

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
	load_item_database()
	SaveManager.load_setting_config()
	player_stats = default_player_stats

func load_item_database():
	var directory_path = "res://resources/items/"
	var tres_files: Array[Item] = []
	var dir = DirAccess.open(directory_path)

	if dir:
		var files = dir.get_files() # Get all files in the directory
		for file in files:
			if file.ends_with(".tres"):
				var resource = ResourceLoader.load(directory_path + "/" + file)
				if resource:
					tres_files.append(resource as Item)
	else:
		print("Failed to open directory: ", directory_path)
	item_database = tres_files

func reset_save_data():
	player_level = 1
	start_record_timestamp = 0
	total_playtime = 0
	InventoryGlobal.reset_save_data()

func start_record_playtime():
	start_record_timestamp = Time.get_ticks_msec()

func update_total_playtime():
	var played_time = Time.get_ticks_msec() - start_record_timestamp
	total_playtime += played_time
	start_record_timestamp = Time.get_ticks_msec() # Reset start timestamp
