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

func delete_save_file(slot_id: int):
	var save_path = get_savefile_name(slot_id)
	var dir = DirAccess.open("user://")
	
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
	var save_dict = {
		"inventory_dict": convert_item_resource_to_id(InventoryGlobal.inventory_dict),
		"player_level": Globals.player_level,
		"player_hp_increase": Globals.player_hp_increase,
		"player_speed_increase": Globals.player_speed_increase,
		"player_damage_increase": Globals.player_damage_increase,
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
		# GameManager.load_new_save_data()
		return

	InventoryGlobal.inventory_dict = convert_id_to_item_resource(save_data["inventory_dict"])
	Globals.player_level = save_data["player_level"]
	Globals.player_hp_increase = save_data["player_hp_increase"]
	Globals.player_speed_increase = save_data["player_speed_increase"]
	Globals.player_damage_increase = save_data["player_damage_increase"]
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
