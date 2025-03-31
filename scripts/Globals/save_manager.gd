extends Node

var save_data_is_loaded = false
var is_saving = false

signal started_saving
signal finished_saving
signal setting_config_loaded

func _ready() -> void:
	load_setting_config()

func convert_item_resource_to_id(resource_dict: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key in resource_dict:
		var item_id = key.item_id
		result[item_id] = resource_dict[key]
	return result

func convert_id_to_item_resource(id_dict: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for item_id in id_dict:
		for db_item in Globals.item_database:
			if db_item.item_id == int(item_id):
				result[db_item] = id_dict[item_id]
	return result

func convert_inventory_data_when_save(inventory_dict: Dictionary):
	var new_dict = {
		0: null,
		1: {},
		2: {}
	}
	new_dict[1] = convert_item_resource_to_id(inventory_dict[1])
	new_dict[2] = convert_item_resource_to_id(inventory_dict[2])
	return new_dict

func convert_inventory_data_when_load(saved_dict: Dictionary):
	var new_dict = {
		0: null,
		1: {},
		2: {}
	}
	new_dict[1] = convert_id_to_item_resource(saved_dict["1"])
	new_dict[2] = convert_id_to_item_resource(saved_dict["2"])
	return new_dict

func save_inventory(inventory_dict: Dictionary, slot_id: int):
	var path = "res://resources/inventory_saves/file" + str(slot_id) +  ".tres"
	var save_file: InventorySave = load(path)
	save_file.player_inventory = inventory_dict[InventoryGlobal.InventoryType.PLAYER]
	save_file.fridge_inventory = inventory_dict[InventoryGlobal.InventoryType.FRIDGE]
	ResourceSaver.save(save_file, path)
	
func load_inventory(slot_id: int):
	var path = "res://resources/inventory_saves/file" + str(slot_id) +  ".tres"
	var save_file: InventorySave = load(path)
	InventoryGlobal.inventory_dict[InventoryGlobal.InventoryType.PLAYER] = save_file.player_inventory
	InventoryGlobal.inventory_dict[InventoryGlobal.InventoryType.FRIDGE] = save_file.fridge_inventory
	
func delete_save_file(slot_id: int):
	var save_path = get_savefile_name(slot_id)
	var dir = DirAccess.open("user://")
	
	# Clear inventory resource
	var path = "res://resources/inventory_saves/file" + str(slot_id) +  ".tres"
	var save_file: InventorySave = load(path)
	save_file.reset_inventories()
	ResourceSaver.save(save_file, path)
	
	if dir and dir.file_exists(save_path):
		var result = dir.remove(save_path)
		if result == OK:
			print("Save file deleted successfully.")
		else:
			print("Failed to delete save file.")
	else:
		print("Save file does not exist.")

func save_game(slot_id):
	Globals.update_total_playtime()
	is_saving = true
	started_saving.emit()
	
	var player_stats = Globals.player_stats.export_stats()
	save_inventory(InventoryGlobal.inventory_dict, slot_id)
	var save_dict = {
		#"inventory_dict": convert_inventory_data_when_save(InventoryGlobal.inventory_dict),
		"player_stats": player_stats,
		"total_playtime": Globals.total_playtime,
	}
	var save_file = FileAccess.open(get_savefile_name(slot_id), FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	save_file.store_line(json_string)
	is_saving = false
	finished_saving.emit()

func load_data_only(slot_id: int) -> Dictionary:
	var save_data: Dictionary = {}
	if not FileAccess.file_exists(get_savefile_name(slot_id)):
		return save_data # Error! We don't have a save to load.

	var save_file = FileAccess.open(get_savefile_name(slot_id), FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()

		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		for key in json.data.keys():
			save_data[key] = json.data[key]

	return save_data

func load_game(slot_id):
	save_data_is_loaded = true

	var save_data = load_data_only(slot_id)
	if save_data.is_empty():
		return

	#InventoryGlobal.inventory_dict = convert_inventory_data_when_load(save_data["inventory_dict"])
	load_inventory(slot_id)
	Globals.player_stats.load_stats(save_data["player_stats"])
	Globals.total_playtime = save_data["total_playtime"]

func get_savefile_name(slot_id: int) -> String:
	return "user://savegame_slot{0}.save".format([slot_id])


func save_setting_config():
	var config = ConfigFile.new()

	# TODO: Save keybind
	config.set_value("Display", "fps_limit_index", Globals.fps_limit_index)
	config.set_value("Display", "resolution_index", Globals.resolution_index)
	config.set_value("Display", "window_mode_index", Globals.window_mode_index)
	config.set_value("Audio", "master_volume", Globals.master_volume)
	config.set_value("Audio", "music_volume", Globals.music_volume)
	config.set_value("Audio", "effects_volume", Globals.effects_volume)
	config.set_value("Audio", "ui_volume", Globals.ui_volume)

	config.save("user://setting.cfg")


func load_setting_config():
	var config = ConfigFile.new()

	var err = config.load("user://setting.cfg")

	# If the file didn't load, ignore it.
	if err != OK:
		return

	Globals.fps_limit_index = config.get_value("Display", "fps_limit_index", 2)
	Globals.resolution_index = config.get_value("Display", "resolution_index", 1)
	Globals.window_mode_index = config.get_value("Display", "window_mode_index", 1)
	Globals.master_volume = config.get_value("Audio", "master_volume", 80)
	Globals.music_volume = config.get_value("Audio", "music_volume", 100)
	Globals.effects_volume = config.get_value("Audio", "effects_volume", 100)
	Globals.ui_volume = config.get_value("Audio", "ui_volume", 100)

	setting_config_loaded.emit()
