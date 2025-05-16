extends Node

## On Windows, save location probably in sth like this:
## C:\Users\[Username]\AppData\Roaming\Godot\app_userdata\Team-Rocket Game

var save_data_is_loaded = false
var is_saving = false

signal started_saving
signal finished_saving
signal setting_config_loaded

func _ready() -> void:
	load_setting_config()

func save_inventory(inventory_dict: Dictionary):
	var output_dict = {}
	for inv in inventory_dict:
		if (inventory_dict.get(inv) != null):
			var output_inv: Array = []
			for item: Item in inventory_dict[inv].keys():
				var output_item = {}
				output_item["item"] = item.save()
				output_item["amount"] = inventory_dict[inv][item]
				output_inv.append(output_item)
			output_dict[inv] = output_inv
	return output_dict

func load_inventory(inventory_dict: Dictionary):
	var parsed_dict = {}
	# Check every inventory option (None, Player, Fridge)
	for inv in InventoryGlobal.inventory_dict:
		var inv_str = str(inv)
		var inv_dict = {}
		# If it is not null (none)
		if (inventory_dict.get(inv_str) != null):
			# Get the inventory from dict and load every item
			var output_inv: Array = inventory_dict[inv_str]
			for item in output_inv:
				var loaded_item: Item = Item.load_item(item["item"])
				inv_dict[loaded_item] = inv_dict.get(loaded_item, 0) + item["amount"]
		parsed_dict[inv] = inv_dict
	return parsed_dict

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

	var player_stats = Globals.player_stats.export_stats()
	var inventory_dict = save_inventory(InventoryGlobal.inventory_dict)
	var save_dict = {
		"player_stats": player_stats,
		"total_playtime": Globals.total_playtime,
		"inventory": inventory_dict,
		"current_day": Globals.current_day,
		"current_requested_dish_idx": Globals.current_requested_dish_idx,
		"devotion": Globals.devotion
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

	InventoryGlobal.inventory_dict = load_inventory(save_data["inventory"])
	Globals.player_stats.load_stats(save_data["player_stats"])
	Globals.total_playtime = save_data["total_playtime"]
	Globals.current_day = save_data.get("current_day", 1)
	Globals.current_requested_dish_idx = save_data.get("current_requested_dish_idx", 0)
	Globals.devotion = save_data.get("devotion", Globals.STARTING_DEVOTION)


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
