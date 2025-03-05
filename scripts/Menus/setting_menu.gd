extends Control
class_name SettingMenu

@export var keybind_button_prefab: PackedScene

@onready var tab_container: TabContainer = $BG/TabContainer
@onready var keybind_container: Control = $BG/TabContainer/Game/ScrollContainer/VBoxContainer/KeybindSection/VBoxContainer/KeybindContainer

signal back

var keybindable_action_list = {
	"up": "Move up",
	"down": "Move down",
	"left": "Move left",
	"right": "Move right",
	"roll": "Roll",
	"sprint": "Sprint",
	"crouch": "Crouch",
	"fire": "Shoot",
	"aim": "Aim",
	"reload": "Reload",
	"channel": "Channel return",
	"interact": "Interact",
	"inventory": "Inventory",
	"debug": "[DEBUG] Debug menu",
	"pause": "Pause",
}
var is_remapping = false
var action_to_remap = null
var remapping_button: KeybindButton = null

func _ready() -> void:
	# refresh_setting_value()
	create_keybind_buttons()
	# SaveManager.setting_config_loaded.connect(refresh_setting_value)

func _input(event):
	if is_remapping:
		if (event is InputEventKey || (event is InputEventMouseButton && event.pressed)):
			if event is InputEventMouseButton && event.double_click:
				event.double_click = false
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			remapping_button.input_button.text = event.as_text().trim_suffix(" (Physical)")
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			accept_event()


func create_keybind_buttons():
	for child in keybind_container.get_children():
			child.queue_free()
	InputMap.load_from_project_settings()
	for action in keybindable_action_list:
		var button_inst: KeybindButton = keybind_button_prefab.instantiate()
		keybind_container.add_child(button_inst)
		button_inst.action_label.text = keybindable_action_list[action]
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			button_inst.input_button.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			button_inst.input_button.text = ""
		button_inst.input_button.pressed.connect(_on_input_button_pressed.bind(button_inst, action))
		button_inst.input_button.mouse_entered.connect(play_button_hover_sfx)

# func refresh_setting_value():
# 	mouse_sen_slider.value = GameManager.mouse_sensitivity
# 	mouse_sen_value.text = "{0}".format([GameManager.mouse_sensitivity])

# 	fov_slider.value = GameManager.camera_fov
# 	fov_value.text = "{0}".format([GameManager.camera_fov])

# 	camera_tilt_toggle.set_pressed_no_signal(GameManager.camera_tilt)

# 	Engine.max_fps = GameManager.FPS_LIMIT_ARRAY[GameManager.fps_limit_index]
# 	fps_limit_option_button.selected = GameManager.fps_limit_index

# 	DisplayServer.window_set_vsync_mode(GameManager.vsync_option_index)
# 	vsync_option_button.selected = GameManager.vsync_option_index

# 	DisplayServer.window_set_size(GameManager.RESOLUTION_ARRAY[GameManager.resolution_index])
# 	resolution_option_button.selected = GameManager.resolution_index

# 	set_window_mode(GameManager.window_mode_index)
# 	window_mode_option_button.selected = GameManager.window_mode_index

# 	get_viewport().set_scaling_3d_scale(GameManager.scaling_3d / 100.0)
# 	scaling_3d_slider.value = GameManager.scaling_3d
# 	scaling_3d_value.text = "{0}%".format([GameManager.scaling_3d])

# 	# TODO - update these to use the more recent SoundManager version (or downgrade SoundManager)
# 	#SoundManager.set_master_volume(GameManager.master_audio / 100.0)
# 	#SoundManager.set_music_volume(GameManager.bgm_audio / 100.0)
# 	#SoundManager.set_sound_volume(GameManager.sfx_audio / 100.0)
# 	#SoundManager.set_ui_sound_volume(GameManager.ui_audio / 100.0)
# 	master_slider.value = GameManager.master_audio
# 	master_value.text = "{0}".format([GameManager.master_audio])
# 	bgm_slider.value = GameManager.bgm_audio
# 	bgm_value.text = "{0}".format([GameManager.bgm_audio])
# 	sfx_slider.value = GameManager.sfx_audio
# 	sfx_value.text = "{0}".format([GameManager.sfx_audio])
# 	ui_slider.value = GameManager.ui_audio
# 	ui_value.text = "{0}".format([GameManager.ui_audio])
	
func _on_input_button_pressed(button: KeybindButton, action):
	if not is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.input_button.text = "Press key to bind..."

func _on_reset_keybind_button_pressed():
	create_keybind_buttons()

func _on_back_button_pressed() -> void:
	back.emit()

func _on_game_tab_button_pressed() -> void:
	SoundManager.play_button_click_sfx()
	tab_container.current_tab = 0

func _on_display_tab_button_pressed() -> void:
	SoundManager.play_button_click_sfx()
	tab_container.current_tab = 1

func _on_audio_tab_button_pressed() -> void:
	SoundManager.play_button_click_sfx()
	tab_container.current_tab = 2

func play_button_hover_sfx():
	SoundManager.play_button_hover_sfx()
