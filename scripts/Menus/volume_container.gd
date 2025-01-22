extends HBoxContainer

enum SETTING_NAME {MASTER, EFFECTS, MUSIC, UI}
@export var setting: SETTING_NAME
@export var setting_name: String

@onready var label: Label = $Label
@onready var amount: Label = $Amount
@onready var slider: HSlider = $Slider

func _ready() -> void:
	label.text = setting_name
	slider.value = get_slider_value(setting)

func change_slider_value(setting, value):
	match setting:
		SETTING_NAME.MASTER:
			Settings.master_volume = value
		SETTING_NAME.EFFECTS:
			Settings.effects_volume = value
		SETTING_NAME.MUSIC:
			Settings.music_volume = value
		SETTING_NAME.UI:
			Settings.ui_volume = value
			
func get_slider_value(setting):
	match setting:
			SETTING_NAME.MASTER:
				return Settings.master_volume
			SETTING_NAME.EFFECTS:
				return Settings.effects_volume
			SETTING_NAME.MUSIC:
				return Settings.music_volume
			SETTING_NAME.UI:
				return Settings.ui_volume

func _on_slider_value_changed(value: float) -> void:
	amount.text = str((slider.value / 1.0) * 100) + "%"
	change_slider_value(setting, slider.value)
