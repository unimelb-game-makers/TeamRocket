extends Storage

signal submit(item)

@onready var inventory_select_list: Container = $CanvasLayer/UI/InventorySelectList
@onready var canvas_layer: CanvasLayer = $CanvasLayer

@export var acceptable_foods: Array[Item]

func _ready() -> void:
	sprite.material.set_shader_parameter("outline_color", Color.YELLOW)
	for i in range(slots_num):
		var item_slot = item_slot_scene.instantiate()
		item_slot.index = i
		item_containers.add_child(item_slot)
		item_slot.food_removed.connect(take_item)
	update_display()

func submit_item(item):
	submit.emit(item)
	items[0] = null
	update_display()

func interact():
	canvas_layer.visible = not canvas_layer.visible
	item_containers.visible = not item_containers.visible
	inventory_select_list.update_inventory_list()

func take_item(slot):
	super (slot)
	inventory_select_list.update_inventory_list()

func _on_submit_button_pressed() -> void:
	if (items[0] in acceptable_foods):
		submit_item(items[0])

func _on_inventory_select_list_item_selected(item: Item, _amount: int) -> void:
	if items[0] == null:
		items[0] = item
		InventoryGlobal.remove_item(item, 1)
		inventory_select_list.update_inventory_list()
		update_display()


func _on_body_entered(_body: Node2D) -> void:
	sprite.material.set_shader_parameter("outline_color", Color.GREEN)


func _on_body_exited(_body: Node2D) -> void:
	canvas_layer.hide()
	sprite.material.set_shader_parameter("outline_color", Color.YELLOW)
	item_containers.hide()


func _on_reset_button_pressed() -> void:
	for slot in item_containers.get_children():
		slot.remove_food()
