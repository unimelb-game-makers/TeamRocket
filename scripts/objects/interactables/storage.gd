extends Area2D
class_name Storage

@export var slots_num: int
@export var item_slot_scene: PackedScene
@export var storage_ui: Control
@export var randomized_loot = true

@onready var item_containers: GridContainer = %ItemContainers
@onready var sprite: Sprite2D = $Sprite2D

signal get_item(item, amount)

var open_state = false
var items: Array[Item] = []

func _ready() -> void:
	for i in range(slots_num):
		items.append(null)
	sprite.material.set_shader_parameter("thickness", 0)

	for child in item_containers.get_children():
		child.queue_free()

	for i in range(slots_num):
		var item_slot = item_slot_scene.instantiate()
		item_slot.index = i
		item_containers.add_child(item_slot)
		item_slot.food_removed.connect(take_item)

	await get_tree().process_frame
	await get_tree().process_frame

	update_display()

func generate_loot(loot_table: Array[Item]):
	var loot_array: Array[Item] = []
	var n_item_to_spawn = randi_range(0, slots_num - 1)
	for i in range(n_item_to_spawn):
		var loot_idx = randi_range(0, len(loot_table) - 1)
		loot_array.append(loot_table[loot_idx])
	while loot_array.size() < slots_num:
		loot_array.append(null)

	items = loot_array


func interact():
	storage_ui.visible = not storage_ui.visible

func add_item(item: Item):
	if (items.size() < slots_num):
		items.append(item)

func take_item(slot):
	var item = items[slot]
	#print(item, item.get_scene_unique_id())
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
