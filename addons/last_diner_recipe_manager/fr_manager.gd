@tool
extends EditorPlugin

const FoodPanel = preload("res://addons/last_diner_recipe_manager/main_manager.tscn")

var food_panel_instance
var file_selector: EditorFileDialog

func _enter_tree():
	food_panel_instance = FoodPanel.instantiate()
	EditorInterface.get_editor_main_screen().add_child(food_panel_instance)
	_make_visible(false)
	
func _exit_tree():
	if food_panel_instance:
		food_panel_instance.queue_free()

func _has_main_screen():
	return true

func _make_visible(visible):
	if food_panel_instance:
		food_panel_instance.visible = visible

func _get_plugin_name():
	return "Food and Recipe Manager"

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")

func make_file_selector():
	if (file_selector):
		file_selector.queue_free()
	var file_selector = EditorFileDialog.new()
	add_child(file_selector)
	file_selector.size = get_tree().root.size / 2
	file_selector.position = Vector2i(40, 40)
	file_selector.title = "Select a texture file"
	file_selector.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	file_selector.show()
