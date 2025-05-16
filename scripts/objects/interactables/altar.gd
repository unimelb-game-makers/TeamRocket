extends Storage

signal submit(item)

@onready var inventory_select_list: CenterContainer = $UI/CanvasLayer/InventorySelectList
@onready var canvas_layer: CanvasLayer = $UI/CanvasLayer

@export var acceptable_foods: Array[Dish]

func submit_item(item):
	submit.emit(item)
	items[0] = null
	update_display()

func interact():
	super()
	canvas_layer.visible = not canvas_layer.visible
	inventory_select_list.update_inventory_list()

func take_item(slot):
	super(slot)
	inventory_select_list.update_inventory_list()

func _on_submit_button_pressed() -> void:
	if (items[0] in acceptable_foods):
		submit_item(items[0])

func _on_reset_button_pressed() -> void:
	for slot in item_containers.get_children():
		slot.remove_food()


func _on_inventory_container_item_select(item: Item, _amount: int) -> void:
	if items[0] == null:
		items[0] = item
		InventoryGlobal.remove_item(item, 1)
		inventory_select_list.update_inventory_list()
		update_display()


func _on_area_entered(_area: Area2D) -> void:
	sprite.material.set_shader_parameter("outline_color", Color.GREEN)


func _on_area_exited(_area: Area2D) -> void:
	canvas_layer.hide()
	sprite.material.set_shader_parameter("outline_color", Color.YELLOW)
	item_containers.hide()
