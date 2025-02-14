extends Control

signal item_selected(item, amount)

@onready var inventory_container: CenterContainer = $ItemListBackground/InventoryContainer
@onready var item_descriptor: ColorRect = $ItemDescriptionBackground

var is_open = false
func update_weight_label():
	$ItemListBackground/WeightLabel.text = "Weight: " + str(Inventory_Global.get_total_weight()) + "kg"

func _ready() -> void:
	Globals.inventory_ui = self
	update_character_stats()
	update_weight_label()

func _on_inventory_container_item_selected(item: Item, amount: int) -> void:
	item_selected.emit(item, amount)
	item_descriptor.update_description_info(item)

func update_character_stats():
	$CharacterStats/Stats/HpLabel.text = "HP: " + str(50*(1+Globals.player_hp_increase))
	$CharacterStats/Stats/DmgLabel.text = "DMG: " + str(5*(1+Globals.player_damage_increase))
	$CharacterStats/Stats/SpdLabel.text = "SPD: " + str(1+Globals.player_speed_increase)
	
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("inventory")):
		toggle_inventory(not is_open)

func toggle_inventory(status: bool) -> void:
	visible = status
	is_open = visible

func update_description(item: Item, amount: int):
	item_descriptor.update_description_info(item)
