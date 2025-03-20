extends Control
class_name InventoryUI

signal item_selected(item, amount)

@onready var hp_label: Label = $CharacterStats/Stats/HpLabel
@onready var dmg_label: Label = $CharacterStats/Stats/DmgLabel
@onready var speed_label: Label = $CharacterStats/Stats/SpdLabel
@onready var weight_label: Label = $VBoxContainer/ItemListBackground/WeightLabel
@onready var inventory_container: CenterContainer = $VBoxContainer/ItemListBackground/InventoryContainer
@onready var item_descriptor: Control = $VBoxContainer/ItemDescriptionBackground

var is_open = false
func update_weight_label():
	weight_label.text = "Weight: " + str(InventoryGlobal.get_total_weight()) + "kg"

func _ready() -> void:
	Globals.inventory_ui = self
	update_character_stats()
	update_weight_label()

func _on_inventory_container_item_selected(item: Item, amount: int) -> void:
	item_selected.emit(item, amount)
	item_descriptor.update_description_info(item)

func update_character_stats():
	hp_label.text = "HP: " + str(50 * (1 + Globals.player_hp_increase))
	dmg_label.text = "DMG: " + str(5 * (1 + Globals.player_damage_increase))
	speed_label.text = "SPD: " + str(1 + Globals.player_speed_increase)

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("inventory")):
		toggle_inventory(not is_open)

func toggle_inventory(status: bool) -> void:
	visible = status
	is_open = visible

func update_description(item: Item, amount: int):
	item_descriptor.update_description_info(item)
