extends Control
class_name InventoryUI

signal item_selected(item, amount)

@onready var hp_label: Label = $CharacterStats/Stats/HpLabel
@onready var dmg_label: Label = $CharacterStats/Stats/DmgLabel
@onready var speed_label: Label = $CharacterStats/Stats/SpdLabel
@onready var weight_label: Label = $VBoxContainer/ItemListBackground/WeightLabel
@onready var inventory_select_list: Container = $VBoxContainer/ItemListBackground/InventorySelectList
@onready var item_descriptor: ItemDescriptionBox = $VBoxContainer/ItemDescriptionBackground
@onready var drop_button: Button = $VBoxContainer/ItemListBackground/ContextButtonList/DropButton

var is_open = false
var current_selected_item: Item = null

func _ready() -> void:
	Globals.inventory_ui = self
	update_character_stats()
	update_weight_label()
	drop_button.disabled = true


func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("inventory")):
		toggle_inventory(not is_open)

func update_weight_label():
	weight_label.text = "Weight: " + str(InventoryGlobal.get_total_weight()) + "kg"

func update_character_stats():
	hp_label.text = "HP: " + str(50 * (1 + Globals.player_hp_increase))
	dmg_label.text = "DMG: " + str(5 * (1 + Globals.player_damage_increase))
	speed_label.text = "SPD: " + str(1 + Globals.player_speed_increase)


func toggle_inventory(status: bool) -> void:
	visible = status
	is_open = visible
	reset_data()

func update_description(item: Item, _amount: int):
	item_descriptor.update_description_info(item)

func reset_data():
	drop_button.disabled = true
	item_descriptor.reset_display()
	current_selected_item = null


func _on_inventory_select_list_item_select(item: Item, amount: int) -> void:
	current_selected_item = item
	item_selected.emit(item, amount)
	item_descriptor.update_description_info(item)
	drop_button.disabled = false


func _on_drop_button_pressed() -> void:
	if current_selected_item:
		var amount_left = InventoryGlobal.drop_item(current_selected_item, 1)
		if amount_left == 0:
			drop_button.disabled = true