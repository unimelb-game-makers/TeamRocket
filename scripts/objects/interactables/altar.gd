extends Storage

signal submit(item: Item)

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var inventory_container: Container = $CanvasLayer/UI/InventoryMenu/InventoryArea/InventoryContainer
@onready var wanted_food_label: RichTextLabel = $CanvasLayer/UI/SubmitArea/WantedFoodLabel
@onready var item_name_label: Label = $CanvasLayer/UI/InventoryMenu/ItemDescriptionArea/ItemName
@onready var item_description_label: Label = $CanvasLayer/UI/InventoryMenu/ItemDescriptionArea/ItemDescription
@onready var item_image: TextureRect = $CanvasLayer/UI/InventoryMenu/ItemDescriptionArea/ItemImage
@onready var item_shadow: TextureRect = $CanvasLayer/UI/SubmitArea/ItemShadow
@onready var item_image_for_dissolve: TextureRect = $CanvasLayer/UI/SubmitArea/ItemImageForDissolve
@onready var submit_button: Button = $CanvasLayer/UI/SubmitArea/SubmitButton

var offering_slot: FoodSlot
var is_judging = false

func _ready() -> void:
	super ()
	canvas_layer.visible = false
	update_wanted_food_label()
	sprite.material.set_shader_parameter("thickness", 5)

	await get_tree().process_frame
	await get_tree().process_frame

	# Hide the button texture
	offering_slot = item_containers.get_child(0)
	offering_slot.button.self_modulate = Color(1, 1, 1, 0)


func submit_item(item):
	if is_judging:
		return
	submit.emit(item)
	items[0] = null

	dissolve_food_image()
	judge_food(item)

	update_display()

	# Simulate go to next day
	# Globals.current_day += 1
	# Globals.game_handler.switch_to_kitchen()


func interact():
	clear_item_description_area_data()
	canvas_layer.visible = not canvas_layer.visible
	inventory_container.update_inventory_list()
	update_wanted_food_label()
	update_display()

func take_item(slot):
	super (slot)
	inventory_container.update_inventory_list()
	item_shadow.visible = false


func update_display():
	super ()
	if items[0] != null:
		item_shadow.visible = true
	else:
		item_shadow.visible = false


func dissolve_food_image():
	item_containers.visible = false
	submit_button.disabled = true
	is_judging = true
	var burn_duration = 1.0
	item_image_for_dissolve.visible = true
	item_image_for_dissolve.texture = offering_slot.food_texture.texture
	item_image_for_dissolve.size = offering_slot.food_texture.size
	item_image_for_dissolve.scale = item_containers.scale
	item_image_for_dissolve.global_position = offering_slot.food_texture.global_position
	item_image_for_dissolve.material.set_shader_parameter("dissolve_value", 1.0)
	var tween = create_tween()
	tween.tween_method(
		func(value): item_image_for_dissolve.material.set_shader_parameter("dissolve_value", value),
		1.0, # Start value
		0.0, # End value
		burn_duration # Duration
	);
	await get_tree().create_timer(burn_duration).timeout
	# item_image_for_dissolve.visible = false
	item_containers.visible = true
	submit_button.disabled = false
	is_judging = false

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
	wanted_food_label.text = "[shake][color=gray]He want {0}[/color][/shake]".format([wanted_dish.item_name])

func update_item_description_area(item: Item):
	item_name_label.text = item.item_name
	item_description_label.text = item.description
	item_image.texture = item.texture

func clear_item_description_area_data():
	item_name_label.text = ""
	item_description_label.text = ""
	item_image.texture = null


func _on_submit_button_pressed() -> void:
	submit_item(items[0])

func _on_reset_button_pressed() -> void:
	for slot in item_containers.get_children():
		slot.remove_food()


func _on_inventory_container_item_select(item: Item, _amount: int) -> void:
	if is_judging:
		return
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


func _on_inventory_container_item_hover(item: Item, _amount: int) -> void:
	update_item_description_area(item)
