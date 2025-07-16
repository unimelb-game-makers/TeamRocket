extends Control
class_name InventoryUI

signal item_selected(item, amount)

@export var status_slot: PackedScene

@onready var hp_label: Label = $CharacterStats/Stats/HpLabel
@onready var dmg_label: Label = $CharacterStats/Stats/DmgLabel
@onready var speed_label: Label = $CharacterStats/Stats/SpdLabel
@onready var weight_label: Label = $VBoxContainer/ItemListBackground/WeightLabel

@onready var inventory_container: Container = $VBoxContainer/ItemListBackground/InventoryContainer
@onready var item_descriptor: ItemDescriptionBox = $VBoxContainer/ItemDescriptionBackground

@onready var drop_button: Button = $VBoxContainer/ItemListBackground/ContextButtonList/DropButton
@onready var devotion_label: Label = $CharacterStats/Stats/DevotionLabel
@onready var use_button: TemplateButton = $VBoxContainer/ItemListBackground/ContextButtonList/UseButton
@onready var status_grid_container: GridContainer = $StatusPanel/StatusGridContainer

var can_open = true
var is_open = false
var current_selected_item: Item = null

func _ready() -> void:
	Globals.inventory_ui = self
	Globals.devotion_changed.connect(func(value): devotion_label.text = "Devotion: {0}".format([value]))
	await get_tree().process_frame
	await get_tree().process_frame
	inventory_container.update_inventory_list()
	reset_data()

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("inventory") and can_open):
		toggle_inventory(not is_open)

func update_weight_label():
	weight_label.text = "Weight: " + str(InventoryGlobal.get_total_weight()) + "kg"

func update_character_stats():
	hp_label.text = "HP: {0} / {1}".format([Globals.player_stats.health, Globals.player_stats.max_health])
	dmg_label.text = "DMG: {0}".format([Globals.player_stats.damage])
	speed_label.text = "SPD: {0}".format([Globals.player_stats.speed])
	devotion_label.text = "Devotion: {0}".format([Globals.devotion])

func update_status_panel():
	for child in status_grid_container.get_children():
		child.queue_free()
	for status in Globals.player_stats.status_effects:
		var info = Globals.player_stats.status_effects[status]
		var status_inst = status_slot.instantiate()
		status_grid_container.add_child(status_inst)
		status_inst.set_status(status, info[0], info[1])

func toggle_inventory(status: bool) -> void:
	visible = status
	is_open = visible
	Globals.player.can_interact = not is_open
	Globals.player.can_move = not is_open
	reset_data()

func update_description(item: Item, _amount: int):
	item_descriptor.update_description_info(item)

func reset_data():
	drop_button.disabled = true
	item_descriptor.reset_display()
	current_selected_item = null
	update_character_stats()
	update_weight_label()

func _on_inventory_container_item_select(item: Item, amount: int) -> void:
	current_selected_item = item
	item_descriptor.update_description_info(item)
	item_selected.emit(item, amount)
	drop_button.disabled = false
	if (current_selected_item is Dish):
		use_button.disabled = false
	else:
		use_button.disabled = true

func _on_drop_button_pressed() -> void:
	SoundManager.play_button_click_sfx()
	if current_selected_item:
		var amount_left = InventoryGlobal.drop_item(current_selected_item, 1)
		if amount_left == 0:
			drop_button.disabled = true

func _on_use_button_pressed() -> void:
	SoundManager.play_button_hover_sfx()
	if current_selected_item is Dish:
		InventoryGlobal.remove_item(current_selected_item, 1)
		Globals.player.eat_food(current_selected_item)
		if not InventoryGlobal.has_item(current_selected_item, 1):
			use_button.disabled = true

func play_button_hover_sfx():
	SoundManager.play_button_hover_sfx()
