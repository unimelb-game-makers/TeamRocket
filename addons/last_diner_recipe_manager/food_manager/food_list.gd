@tool
extends VBoxContainer

@export var food_res_folder: String
@export var food_instance_scene: PackedScene

signal food_selected(item, path)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_from_files()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_from_files() -> void:
	var food_resources = DirAccess.get_files_at(food_res_folder)
	for file in food_resources:
		var item = load(food_res_folder + "/" + file)
		var food_selection = food_instance_scene.instantiate()
		food_selection.item = item
		food_selection.path = file
		food_selection.selected_item.connect(emit_food_selected)
		add_child(food_selection)
		
func emit_food_selected(item, path) -> void:
	food_selected.emit(item, path)
