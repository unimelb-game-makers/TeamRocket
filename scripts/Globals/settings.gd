extends Node

var master_volume: float = 1
var effects_volume: float = 1
var music_volume: float = 1
var ui_volume: float = 1

func _process(delta: float) -> void:
	print(master_volume)