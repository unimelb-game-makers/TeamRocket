extends HBoxContainer

enum SETTING_NAME {MASTER, EFFECTS, MUSIC, UI}
@export var setting: SETTING_NAME
@export var setting_name: String

@onready var label: Label = $Label
@onready var amount: Label = $Amount
@onready var slider: HSlider = $Slider

func _ready() -> void:
	label.text = setting_name

func change_slider_value(setting, value):
	print(value)
	match setting:
		SETTING_NAME.MASTER:
			Settings.master_volume = value
		SETTING_NAME.EFFECTS:
			Settings.effects_volume = value
		SETTING_NAME.MUSIC:
			Settings.music_volume = value
		SETTING_NAME.UI:
			Settings.ui_volume = value


func _on_slider_value_changed(value: float) -> void:
	amount.text = str((slider.value / 1.0) * 100) + "%"
	change_slider_value(setting, slider.value)
