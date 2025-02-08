extends Node

var master_volume: float = 1:
	set(value):
		master_volume = value
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
var effects_volume: float = 1:
	set(value):
		effects_volume = value
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear_to_db(value))
var music_volume: float = 1:
	set(value):
			music_volume = value
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
var ui_volume: float = 1:
	set(value):
			ui_volume = value
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("UI"), linear_to_db(value))
