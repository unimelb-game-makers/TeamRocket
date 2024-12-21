extends Control

var is_open = false

@onready var item_description: ColorRect = $Inventory/ItemDescriptionBackground
@onready var item_list: ColorRect = $Inventory/ItemListBackground

func _ready() -> void:
	Globals.inventory_ui = self
	
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("inventory")):
		toggle_inventory(not is_open)

func toggle_inventory(status: bool) -> void:
	visible = status
	is_open = visible

func update_description(item: Item, amount: int):
	item_description.update_description_info(item)
