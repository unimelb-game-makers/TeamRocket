extends Storage
class_name Altar

signal submit(item: Item)
signal is_interacting_with(state: bool)

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var main_ui: Control = $CanvasLayer/UI
@onready var inventory_container: Container = $CanvasLayer/UI/InventoryMenu/InventoryArea/InventoryContainer
@onready var item_name_label: Label = $CanvasLayer/UI/InventoryMenu/ItemDescriptionArea/ItemName
@onready var item_description_label: Label = $CanvasLayer/UI/InventoryMenu/ItemDescriptionArea/ItemDescription
@onready var item_image: TextureRect = $CanvasLayer/UI/InventoryMenu/ItemDescriptionArea/ItemImage
@onready var item_shadow: TextureRect = $CanvasLayer/UI/SubmitArea/ItemShadow
@onready var item_image_for_dissolve: TextureRect = $CanvasLayer/UI/SubmitArea/ItemImageForDissolve
@onready var submit_button: Button = $CanvasLayer/UI/SubmitArea/SubmitButton
@onready var wanted_food_label_timer: Timer = $WantedFoodLabelTimer
@onready var wanted_food_label: RichTextLabel = $CanvasLayer/UI/SubmitArea/WantedFoodLabel
@onready var result_label: RichTextLabel = $CanvasLayer/ResultLabel

var offering_slot: FoodSlot
var judged = false
var passed = false
var entity_names = ["It", "They", "The entity", "The god"]
var demand_words = ["want", "desire", "request", "demand"]
var entity_unhappy_words = ["displeased", "unhappy", "unsatisfied", ]
var entity_happy_words = ["pleased", "enjoyed", "satisfied"]

var food_words = ["offering", "dish", "tribute", "food"]
var food_bad_words = ["unsatisfactory", "incorrect", "unworthy"]
var food_good_words = ["satisfactory", "correct", "worthy"]

var burn_duration = 2.0

func _ready() -> void:
	super ()
	canvas_layer.visible = false
	result_label.visible = false
	update_wanted_food_label()
	sprite.material.set_shader_parameter("thickness", 5)

	await get_tree().process_frame
	await get_tree().process_frame

	# Hide the button texture
	offering_slot = item_containers.get_child(0)
	offering_slot.button.self_modulate = Color(1, 1, 1, 0)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and (canvas_layer.visible):
		exit_altar_ui()
		get_viewport().set_input_as_handled()


func submit_item(item):
	if judged:
		return
	submit.emit(item)
	items[0] = null

	dissolve_food_image()
	judge_food(item)
	update_display()

	await get_tree().create_timer(burn_duration + 0.5).timeout

	main_ui.visible = false
	show_post_judge_text()

	await get_tree().create_timer(2.0).timeout

	# Simulate go to next day
	if not Globals.check_game_end_condition():
		Globals.current_day += 1
		Globals.game_handler.switch_to_kitchen()


func interact():
	if Globals.is_game_ended or judged:
		return
	clear_item_description_area_data()
	if canvas_layer.visible:
		is_interacting_with.emit(false)
	else:
		is_interacting_with.emit(true)
	canvas_layer.visible = not canvas_layer.visible
	inventory_container.update_inventory_list()
	update_wanted_food_label()
	update_display()

func exit_altar_ui():
	canvas_layer.hide()
	sprite.material.set_shader_parameter("outline_color", Color.YELLOW)
	is_interacting_with.emit(false)

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

	if Globals.current_requested_dish_idx >= Globals.requested_dish_list.size() or Globals.is_game_ended:
		submit_button.disabled = true


func dissolve_food_image():
	wanted_food_label.visible = false
	item_containers.visible = false
	submit_button.disabled = true
	judged = true
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
	item_image_for_dissolve.visible = false
	item_containers.visible = true

func judge_food(submitted_item: Item):
	if Globals.current_requested_dish_idx >= Globals.requested_dish_list.size():
		return
	var wanted_dish = Globals.requested_dish_list[Globals.current_requested_dish_idx]
	if submitted_item is Dish:
		var submitted_dish = submitted_item as Dish
		if submitted_dish.item_name == wanted_dish.item_name:
			Globals.devotion += Globals.PASSED_DEVOTION_BONUS
			passed = true
			Globals.current_requested_dish_idx += 1
			return
	Globals.devotion -= Globals.FAILED_DEVOTION_PENALTY
	wanted_food_label_timer.stop()

func update_wanted_food_label(chaotic = false):
	if Globals.current_requested_dish_idx >= Globals.requested_dish_list.size():
		var no_request = "{0} is silent".format([entity_names.pick_random()])
		wanted_food_label.text = "[shake][color=gray]{0}[/color][/shake]".format([no_request])
		return

	var wanted_dish = Globals.requested_dish_list[Globals.current_requested_dish_idx]
	var final_content = "[font_size=30]He want {0}[/font_size]".format([wanted_dish.item_name])
	if chaotic:
		var rand_font_size = randi_range(20, 40)
		final_content = "[font_size={0}]{1} {2} {3}[/font_size]".format([
			rand_font_size, entity_names.pick_random(), demand_words.pick_random(), wanted_dish.item_name])
	wanted_food_label.text = "[shake][color=gray]{0}[/color][/shake]".format([final_content])

func show_post_judge_text():
	var response_type_arr = ["entity", "food"]
	var rand_font_size = randi_range(40, 60)
	var final_content = ""
	if response_type_arr.pick_random() == "entity":
		var status_text = entity_unhappy_words.pick_random()
		if passed:
			status_text = entity_happy_words.pick_random()
		final_content = "[font_size={0}]{1} is {2}[/font_size]".format([
			rand_font_size, entity_names.pick_random(), status_text])
	else:
		var status_text = food_bad_words.pick_random()
		if passed:
			status_text = food_good_words.pick_random()
		final_content = "[font_size={0}]The {1} is {2}[/font_size]".format([
			rand_font_size, food_words.pick_random(), status_text])

	var text_color = "red"
	if passed:
		text_color = "green"
	result_label.text = "[shake][color={0}][center]{1}[/center][/color][/shake]".format([text_color, final_content])
	result_label.visible = true


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
	SoundManager.play_button_click_sfx()


func _on_reset_button_pressed() -> void:
	for slot in item_containers.get_children():
		slot.remove_food()


func _on_inventory_container_item_select(item: Item, _amount: int) -> void:
	if judged:
		return

	if items[0] == null:
		items[0] = item
		InventoryGlobal.remove_item(item, 1)
		inventory_container.update_inventory_list()
		update_display()


func _on_area_entered(_area: Area2D) -> void:
	sprite.material.set_shader_parameter("outline_color", Color.GREEN)


func _on_area_exited(_area: Area2D) -> void:
	sprite.material.set_shader_parameter("outline_color", Color.YELLOW)
	exit_altar_ui()


func _on_inventory_container_item_hover(item: Item, _amount: int) -> void:
	update_item_description_area(item)


func _on_wanted_food_label_timer_timeout() -> void:
	# Make wanted food text more chaotic
	update_wanted_food_label(true)

func play_hover_sfx():
	SoundManager.play_button_hover_sfx()

func _on_body_exited(_body: Node2D) -> void:
	return

func _on_body_entered(_body: Node2D) -> void:
	return
