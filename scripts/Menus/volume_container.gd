extends HBoxContainer

enum SETTING_NAME {MASTER, EFFECTS, MUSIC, UI}
@export var setting: SETTING_NAME
@export var setting_name: String

@onready var label: Label = $Label
@onready var amount: Label = $Amount
@onready var slider: HSlider = $Slider

func _ready() -> void:
	label.text = setting_name
	slider.value = get_slider_value()

func change_slider_value(value):
	match setting:
		SETTING_NAME.MASTER:
			AudioServer.set_bus_volume_db(0, linear_to_db(value))
			Globals.master_audio = value
		SETTING_NAME.EFFECTS:
			AudioServer.set_bus_volume_db(2, linear_to_db(value))
			Globals.effects_volume = value
		SETTING_NAME.MUSIC:
			AudioServer.set_bus_volume_db(1, linear_to_db(value))
			Globals.music_volume = value
		SETTING_NAME.UI:
			AudioServer.set_bus_volume_db(3, linear_to_db(value))
			Globals.ui_audio = value
			
func get_slider_value():
	match setting:
			SETTING_NAME.MASTER:
				return Globals.master_volume
			SETTING_NAME.EFFECTS:
				return Globals.effects_volume
			SETTING_NAME.MUSIC:
				return Globals.music_volume
			SETTING_NAME.UI:
				return Globals.ui_volume

func _on_slider_value_changed(value: float) -> void:
	amount.text = str((slider.value / 1.0) * 100) + "%"
	change_slider_value(slider.value)
