class_name CookingScene extends Control
"""
CookingScene is the class that functions to allow the user to
pass in ingredients to make an ingredient or a dish depending on the associated
minigame extending class CookingActivity.

CookingActivity minigame is passed into CookingScene as an export
"""
@export var activity_to_run: PackedScene

@onready var ingredient_handler: IngredientHandler = %IngredientHandler
@onready var start_button: TextureButton = $Background/ChosenFoodArea/StartButton
@onready var inventory_container: Container = $Background/InventoryArea/InventoryContainer
@onready var selected_food_list: Container = $Background/ChosenFoodArea/SelectedFoodList
@onready var activity_animated_sprite: TextureRect = $Background/ChosenFoodArea/ActivityAnimatedSprite
@onready var activity_label: Label = $Background/ChosenFoodArea/ActivityLabel

@onready var inventory_area: Control = $Background/InventoryArea
@onready var chosen_food_area: Control = $Background/ChosenFoodArea

@export var activity_name: String
@export var activity_animated_texture: AnimatedTexture

@export var crafting_station: CraftingStation

var activity: CookingActivity
var recipe: Recipe
var activity_is_in_progress = false

signal complete(output)

func _ready() -> void:
	if activity_to_run == null:
		push_error("Cooking Scene does not have an activity to run!!!")

	reset() # Also sets the activity visibility off
	activity_label.text = activity_name
	if activity_animated_texture:
		activity_animated_sprite.texture = activity_animated_texture

func reset():
	ingredient_handler.max_slots = crafting_station.max_ingredients
	ingredient_handler.update_slots()
	inventory_container.update_inventory_list()
	#activity.reset_game() - No point since activity is only created when start button is pressed.

	start_button.visible = true
	ingredient_handler.visible = true
	inventory_container.visible = true
	selected_food_list.visible = true
	#activity.visible = false - NOT NEEDED ANYMORE
	
	inventory_area.visible = true
	chosen_food_area.visible = true

func add_item(item: Ingredient, _amount: int):
	ingredient_handler.add_item(item)

## Creates an instance of the activity, called when start button pressed
## @param input_ingredients: Used to determine minigame difficulty.
## @param output_ingredient: Used to determine minigame difficulty.
func call_and_run_activity(input_ingredients: Array[Ingredient], output_item: Item) -> void:
	activity = activity_to_run.instantiate() as CookingActivity
	activity.complete.connect(finish)
	activity.initialize_activity(input_ingredients, output_item)
	self.add_child(activity) # Starts the activity when it is added due to _ready()

## This method is called when the CookingActivity is finished (emitting signal 'complete')
func finish(rating: float):
	activity_is_in_progress = false
	# Delete the activity
	if activity != null:
		activity.queue_free()

	# Defensive copy of the output item to modify and return?
	var output_item = crafting_station.craft_output(ingredient_handler.selected_ingredients)
	# Modify based on minigame outcome
	output_item.quality = rating
	
	print("\nOutput Item: ")
	print(output_item)
	complete.emit(output_item) # Emit to what?
	InventoryGlobal.add_item(output_item, 1)
	ingredient_handler.clear_slots()
	reset()

func _on_start_button_pressed() -> void:
	# Determine what output ingredient/dish if any
	var output_item = crafting_station.craft_output(ingredient_handler.selected_ingredients)

	# Handles by button is abit weird
	if (output_item):
		start_button.visible = false
		ingredient_handler.visible = false
		selected_food_list.visible = false
		inventory_container.visible = false
		
		inventory_area.visible = false
		chosen_food_area.visible = false
		
		activity_is_in_progress = true
		
		call_and_run_activity(ingredient_handler.selected_ingredients, output_item)
	else:
		print("Output ingredient/dish failed to be generated!")

func _on_ingredient_handler_update_list() -> void:
	inventory_container.update_inventory_list()

func _on_inventory_container_item_select(item: Ingredient, amount: Variant) -> void:
	add_item(item, amount)
