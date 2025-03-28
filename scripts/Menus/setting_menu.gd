class_name SettingMenu
extends Control

@export var keybind_button_prefab: PackedScene

@onready var tab_container: TabContainer = $BG/TabContainer
@onready var keybind_container: Control = $BG/TabContainer/Game/ScrollContainer/MarginContainer/VBoxContainer/KeybindSection/VBoxContainer/KeybindContainer
@onready var fps_limit_option_button: OptionButton = $BG/TabContainer/Display/ScrollContainer/MarginContainer/VBoxContainer/FPS/FPSOptionButton
@onready var vsync_option_button: OptionButton = $BG/TabContainer/Display/ScrollContainer/MarginContainer/VBoxContainer/Vsync/VsyncOptionButton
@onready var window_mode_option_button: OptionButton = $BG/TabContainer/Display/ScrollContainer/MarginContainer/VBoxContainer/WindowMode/WindowOptionButton
@onready var resolution_option_button: OptionButton = $BG/TabContainer/Display/ScrollContainer/MarginContainer/VBoxContainer/Resolution/ResolutionOptionButton
@onready var volume_slider_container = $BG/TabContainer/Audio/ScrollContainer/MarginContainer/VBoxContainer/VBoxContainer

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
	"pause": "Pause",
	"debug": "[DEBUG] Debug UI",
}
var is_remapping = false
var action_to_remap = null
var remapping_button: KeybindButton = null

func _ready() -> void:
	refresh_setting_value()
	create_keybind_buttons()
	SaveManager.setting_config_loaded.connect(refresh_setting_value)

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

func refresh_setting_value():
	Engine.max_fps = Globals.FPS_LIMIT_ARRAY[Globals.fps_limit_index]
	fps_limit_option_button.selected = Globals.fps_limit_index

	DisplayServer.window_set_vsync_mode(Globals.vsync_option_index)
	vsync_option_button.selected = Globals.vsync_option_index

	DisplayServer.window_set_size(Globals.RESOLUTION_ARRAY[Globals.resolution_index])
	resolution_option_button.selected = Globals.resolution_index

	set_window_mode(Globals.window_mode_index)
	window_mode_option_button.selected = Globals.window_mode_index

	# Refresh display value for audio volume sliders
	for child in volume_slider_container.get_children():
		child.refresh_setting_value()
	
func _on_input_button_pressed(button: KeybindButton, action):
	if not is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.input_button.text = "Press key to bind..."

func _on_reset_keybind_button_pressed():
	create_keybind_buttons()

func set_window_mode(index: int) -> void:
	match index:
		0: # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			resolution_option_button.disabled = true
			var resolution_text = str(get_window().get_size().x) + "x" + str(get_window().get_size().y)
			resolution_option_button.set_text(resolution_text)
		1: # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_size(Globals.RESOLUTION_ARRAY[Globals.resolution_index])
			centre_window()
			resolution_option_button.disabled = false
			resolution_option_button.selected = Globals.resolution_index
		2: # Borderless windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_size(Globals.RESOLUTION_ARRAY[Globals.resolution_index])
			centre_window()
			resolution_option_button.disabled = false
			resolution_option_button.selected = Globals.resolution_index

func centre_window():
	var centre_screen = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(centre_screen - window_size / 2)

func _on_window_option_button_item_selected(index: int) -> void:
	set_window_mode(index)
	Globals.window_mode_index = index

func _on_fps_option_button_item_selected(index: int) -> void:
	SoundManager.play_button_click_sfx()
	Engine.max_fps = Globals.FPS_LIMIT_ARRAY[index]
	Globals.fps_limit_index = index

func _on_vsync_option_button_item_selected(index: int) -> void:
	SoundManager.play_button_click_sfx()
	DisplayServer.window_set_vsync_mode(index)
	Globals.vsync_option_index = index

func _on_resolution_option_button_item_selected(index: int) -> void:
	SoundManager.play_button_click_sfx()
	DisplayServer.window_set_size(Globals.RESOLUTION_ARRAY[index])
	Globals.resolution_index = index
	centre_window()

func _on_back_button_pressed() -> void:
	SaveManager.save_setting_config()
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
