extends VBoxContainer

var is_open = false

func _ready() -> void:
	Globals.inventory_ui = self
	
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("inventory")):
		toggle_inventory(not is_open)

func toggle_inventory(status: bool) -> void:
	visible = status
	is_open = visible
