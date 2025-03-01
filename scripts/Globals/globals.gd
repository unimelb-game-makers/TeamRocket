extends Node

var player: Player
var item_handler
var map

var inventory_ui: InventoryUI
var player_ui: PlayerUI
var enemy_handler

var chosen_slot_id = -1 # For saving
var playtime_total = 0

var player_level = 1
var player_hp_increase = 0.0
var player_speed_increase = 0.0
var player_damage_increase = 0.0

var item_database: Array[Item]


func _ready() -> void:
	load_item_database()

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
	player_hp_increase = 0.0
	player_speed_increase = 0.0
	player_damage_increase = 0.0
	InventoryGlobal.reset_save_data()
