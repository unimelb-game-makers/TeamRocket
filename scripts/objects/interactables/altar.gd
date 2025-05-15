extends Storage

signal submit(item: Item)

@onready var inventory_container: Container = $CanvasLayer/UI/InventoryContainer
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var wanted_food_label: Label = $CanvasLayer/UI/WantedFoodLabel

func _ready() -> void:
	super ()
	update_wanted_food_label()
	sprite.material.set_shader_parameter("thickness", 5)


func submit_item(item):
	submit.emit(item)
	judge_food(item)
	items[0] = null
	update_display()

	# Simulate go to next day
	Globals.current_day += 1
	Globals.game_handler.switch_to_kitchen()


func interact():
	canvas_layer.visible = not canvas_layer.visible
	item_containers.visible = not item_containers.visible
	inventory_container.update_inventory_list()
	update_wanted_food_label()

func take_item(slot):
	super (slot)
	inventory_container.update_inventory_list()

func _on_submit_button_pressed() -> void:
	submit_item(items[0])

func _on_reset_button_pressed() -> void:
	for slot in item_containers.get_children():
		slot.remove_food()


func _on_inventory_container_item_select(item: Item, _amount: int) -> void:
	if items[0] == null:
		items[0] = item
		InventoryGlobal.remove_item(item, 1)
		inventory_container.update_inventory_list()
		update_display()


func _on_area_entered(_area: Area2D) -> void:
	sprite.material.set_shader_parameter("outline_color", Color.GREEN)


func _on_area_exited(_area: Area2D) -> void:
	canvas_layer.hide()
	sprite.material.set_shader_parameter("outline_color", Color.YELLOW)
	item_containers.hide()


func judge_food(submitted_item: Item):
	var wanted_dish = Globals.requested_dish_list[Globals.current_requested_dish_idx]
	if submitted_item is Dish:
		var submitted_dish = submitted_item as Dish
		if submitted_dish.item_name == wanted_dish.item_name:
			print("Correct dish!")
			if Globals.current_requested_dish_idx < Globals.requested_dish_list.size() - 1:
				Globals.current_requested_dish_idx += 1
			return
	print("Failed")
	return

func update_wanted_food_label():
	var wanted_dish = Globals.requested_dish_list[Globals.current_requested_dish_idx]
	wanted_food_label.text = "The Entity want {0}".format([wanted_dish.item_name])