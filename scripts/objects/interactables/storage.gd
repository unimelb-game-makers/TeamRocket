class_name Storage
extends Area2D

@export var slots_num: int
@export var items: Array[Item]
@export var item_slot_scene: PackedScene
@export var storage_ui: Control

@onready var item_containers: GridContainer = %ItemContainers
@onready var sprite: Sprite2D = $Sprite2D

signal get_item(item, amount)

var open_state = false

func _ready() -> void:
	sprite.material.set_shader_parameter("thickness", 0)
	for i in range(slots_num):
		var item_slot = item_slot_scene.instantiate()
		item_slot.index = i
		item_containers.add_child(item_slot)
		item_slot.food_removed.connect(take_item)
	update_display()

func interact():
	storage_ui.visible = not storage_ui.visible

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

func _on_body_exited(_body: Node2D) -> void:
	storage_ui.hide()
	sprite.material.set_shader_parameter("thickness", 0)

func _on_body_entered(_body: Node2D) -> void:
	sprite.material.set_shader_parameter("thickness", 5)
