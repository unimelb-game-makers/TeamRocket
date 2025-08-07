class_name ChoppingTrack
extends Control

@onready var bad_range_bar: PanelContainer = $PanelContainer
@onready var good_range_bar: PanelContainer = $PanelContainer2
@onready var perfect_range_bar: PanelContainer = $PanelContainer3

@export var test_setting: ChoppingBoardSettings

func _ready() -> void:
	if get_tree().current_scene == self and test_setting:
		set_ranges(test_setting)

func set_ranges(settings:ChoppingBoardSettings) -> void:
	var total_length = bad_range_bar.size.x
	bad_range_bar.custom_minimum_size.x = bad_range_bar.size.x
	good_range_bar.size.x = total_length * (settings.okay_range/100.0)
	good_range_bar.custom_minimum_size.x = total_length * (settings.okay_range/100.0)
	perfect_range_bar.size.x = total_length * (settings.perfect_range/100.0)
	perfect_range_bar.custom_minimum_size.x = total_length * (settings.perfect_range/100.0)
	#print("Lengths")
	#print(bad_range_bar.size.x)
	#print(total_length * (settings.okay_range/100.0))
	#print(total_length * (settings.perfect_range/100.0))


func _on_resized() -> void:
	#print("Size:", self.size)
	bad_range_bar.size = self.size
	good_range_bar.size.y = self.size.y
	perfect_range_bar.size.y = self.size.y
