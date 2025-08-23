extends Area2D
class_name Storage

@export var slots_num: int = 9
@export var item_slot_scene: PackedScene
@export var storage_ui: Control
@export var randomized_loot = true

@onready var item_containers: GridContainer = %ItemContainers
@onready var sprite: Sprite2D = $Sprite2D
@onready var open_sfx_player: AudioStreamPlayer2D = $OpenSfxPlayer
@onready var close_sfx_player: AudioStreamPlayer2D = $CloseSfxPlayer

var open_state = false
var items: Array[Item] = []

const MIN_AMOUNT_OF_LOOT = 1

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
	var n_item_to_spawn = randi_range(MIN_AMOUNT_OF_LOOT, slots_num - 1)
	for i in range(n_item_to_spawn):
		var loot_idx = randi_range(0, len(loot_table) - 1)
		loot_array.append(loot_table[loot_idx])
	while loot_array.size() < slots_num:
		loot_array.append(null)
	items = loot_array

func load_loot_from_save(contained_items_data):
	for elem in contained_items_data:
		var item: Item = Item.load_item(elem)
		add_item(item)


func interact():
	storage_ui.visible = not storage_ui.visible
	Globals.inventory_ui.visible = not storage_ui.visible
	if storage_ui.visible:
		open_sfx_player.play()
	else:
		close_sfx_player.play()

func add_item(new_item: Item):
	for i in range(len(items)):
		if items[i] == null:
			items[i] = new_item
			return

func take_item(slot):
	var item = items[slot]
	#print(item, item.get_scene_unique_id())
	items[slot] = null
	update_display()
	if (item):
		InventoryGlobal.add_item(item, 1)

func update_display():
	var slots = item_containers.get_children()
	for i in range(slots.size()):
		slots[i].set_ingredient(items[i])

func _on_body_exited(_body: Node2D) -> void:
	if storage_ui.visible:
		close_sfx_player.play()
	storage_ui.hide()
	sprite.material.set_shader_parameter("thickness", 0)

func _on_body_entered(_body: Node2D) -> void:
	sprite.material.set_shader_parameter("thickness", 5)

func get_save_data():
	var contained_items_data = []
	for item in items:
		if item:
			contained_items_data.append(item.save())

	return {
		"name": "crate",
		"type": "storage",
		"slots_num": slots_num,
		"global_position": global_position,
		"contained_items_data": contained_items_data
	}
