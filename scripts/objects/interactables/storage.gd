class_name Storage
extends Area2D

@export var slots_num: int
@export var items: Array[Item]

@export var item_slot_scene: PackedScene = preload("res://scenes/cooking/ui/food_slot.tscn")

@onready var item_containers: GridContainer = %ItemContainers

signal get_item(item, amount)

var open_state = false

func _ready() -> void:
	for i in range(slots_num):
		var item_slot = item_slot_scene.instantiate()
		item_slot.index = i
		item_containers.add_child(item_slot)
		item_slot.remove_food.connect(take_item)
	update_display()

func interact():
	$UI.visible = not $UI.visible

func add_item(item: Item):
	if (items.size() < slots_num):
		items.append(item)

func take_item(slot):
	var item = items[slot]
	items[slot] = null
	update_display()
	if (item):
		InventoryGlobal.add_item(item, 1)

func update_display():
	var slots = item_containers.get_children()
	for slot in range(slots.size()):
		slots[slot].set_ingredient(items[slot])

func _on_area_2d_body_exited(body: Node2D) -> void:
	$UI.hide()


func _on_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
