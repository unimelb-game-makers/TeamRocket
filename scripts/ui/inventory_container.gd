@tool
extends Control

@export var n_slot_column = 5
@export var item_inventory_button_scene: PackedScene
@export var inventory_origin: InventoryGlobal.InventoryType

@onready var grid_container: GridContainer = $GridContainer

signal item_select(item: Item, amount: int)

func _ready() -> void:
	grid_container.columns = n_slot_column
	if not Engine.is_editor_hint():
		update_inventory_list()

func update_inventory_list():
	# KILL ALL CHILDREN
	for child in grid_container.get_children():
		child.queue_free()

	# Render Inventory Items
	var inventory_dict = null
	match inventory_origin:
		InventoryGlobal.InventoryType.PLAYER:
			inventory_dict = InventoryGlobal.get_inventory()
		InventoryGlobal.InventoryType.FRIDGE:
			inventory_dict = InventoryGlobal.get_inventory()

	for item in inventory_dict:
		var item_button = item_inventory_button_scene.instantiate()
		item_button.item = item
		item_button.amount = inventory_dict[item]
		item_button.item_selected.connect(select_item)
		grid_container.add_child(item_button)

func select_item(item, amount):
	item_select.emit(item, amount)

func drop_item(item, amount):
	InventoryGlobal.drop_item(item, amount)
