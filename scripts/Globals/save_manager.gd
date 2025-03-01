extends Node

var save_data_is_loaded = false
var is_saving = false

signal started_saving
signal finished_saving
signal setting_config_loaded

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
	is_saving = true
	started_saving.emit()
	var save_dict = {
		"inventory_dict": convert_item_resource_to_id(InventoryGlobal.inventory_dict),
		"player_level": Globals.player_level,
		"player_hp_increase": Globals.player_hp_increase,
		"player_speed_increase": Globals.player_speed_increase,
		"player_damage_increase": Globals.player_damage_increase,
		"playtime_total": Globals.playtime_total,
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
	Globals.playtime_total = save_data["playtime_total"]


func get_savefile_name(slot_id: int) -> String:
	return "user://savegame_slot{0}.save".format([slot_id])


# func save_setting_config():
# 	var config = ConfigFile.new()

# 	config.set_value("Control", "mouse_sensitivity", GameManager.mouse_sensitivity)
# 	config.set_value("Graphic", "camera_fov", GameManager.camera_fov)
# 	config.set_value("Graphic", "camera_tilt", GameManager.camera_tilt)
# 	config.set_value("Graphic", "fps_limit_index", GameManager.fps_limit_index)
# 	config.set_value("Graphic", "resolution_index", GameManager.resolution_index)
# 	config.set_value("Graphic", "window_mode_index", GameManager.window_mode_index)
# 	config.set_value("Graphic", "scaling_3d", GameManager.scaling_3d)
# 	config.set_value("Audio", "master_audio", GameManager.master_audio)
# 	config.set_value("Audio", "bgm_audio", GameManager.bgm_audio)
# 	config.set_value("Audio", "sfx_audio", GameManager.sfx_audio)
# 	config.set_value("Audio", "ui_audio", GameManager.ui_audio)

# 	config.save("user://setting.cfg")


# func load_setting_config():
# 	var config = ConfigFile.new()

# 	var err = config.load("user://setting.cfg")

# 	# If the file didn't load, ignore it.
# 	if err != OK:
# 		return

# 	GameManager.mouse_sensitivity = config.get_value("Control", "mouse_sensitivity", 50.0)
# 	GameManager.camera_fov = config.get_value("Graphic", "camera_fov", 90)
# 	GameManager.camera_tilt = config.get_value("Graphic", "camera_tilt", true)
# 	GameManager.fps_limit_index = config.get_value("Graphic", "fps_limit_index", 2)
# 	GameManager.resolution_index = config.get_value("Graphic", "resolution_index", 1)
# 	GameManager.window_mode_index = config.get_value("Graphic", "window_mode_index", 1)
# 	GameManager.scaling_3d = config.get_value("Graphic", "scaling_3d", 100.0)
# 	GameManager.master_audio = config.get_value("Audio", "master_audio", 80)
# 	GameManager.bgm_audio = config.get_value("Audio", "bgm_audio", 100)
# 	GameManager.sfx_audio = config.get_value("Audio", "sfx_audio", 100)
# 	GameManager.ui_audio = config.get_value("Audio", "ui_audio", 100)

# 	setting_config_loaded.emit()
