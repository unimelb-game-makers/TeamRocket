extends Control
class_name InventoryUI

signal item_selected(item, amount)

@onready var hp_label: Label = $CharacterStats/Stats/HpLabel
@onready var dmg_label: Label = $CharacterStats/Stats/DmgLabel
@onready var speed_label: Label = $CharacterStats/Stats/SpdLabel
@onready var weight_label: Label = $ItemListBackground/WeightLabel
@onready var inventory_container: CenterContainer = $ItemListBackground/InventoryContainer
@onready var item_descriptor: ColorRect = $ItemDescriptionBackground

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
	pass
	hp_label.text = "HP: " + str(Globals.player_stats.health)
	dmg_label.text = "DMG: " + str(Globals.player_stats.damage)
	speed_label.text = "SPD: " + str(Globals.player_stats.speed)

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("inventory")):
		toggle_inventory(not is_open)

func toggle_inventory(status: bool) -> void:
	visible = status
	is_open = visible

func update_description(item: Item, amount: int):
	item_descriptor.update_description_info(item)
