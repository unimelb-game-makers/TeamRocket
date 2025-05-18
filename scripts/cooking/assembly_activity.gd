extends CookingActivity

@onready var ingredient_image_display: TextureRect = $IngredientImageDisplay
@onready var feedback_label: Label = $FeedbackLabel
@onready var cooking_scene: CookingScene = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_tree().current_scene == self or is_initialized: # Runs if it as current scene or was initialized by something else then added to tree
		feedback_label.text = ("You made " + output_item.item_name)
		set_ingredient_image(output_item)
		await get_tree().create_timer(3).timeout
		complete_minigame()

#func start(input_ingredients: Array[Ingredient], output_item: Item) -> void:
	#feedback_label.text = ("You made " + output_item.item_name)
	#set_ingredient_image(output_item)
	#await get_tree().create_timer(3).timeout
	#complete_minigame()

func complete_minigame() -> void:
	# Simply get average quality of ingredients
	var quality_avg = 0
	for ingredient in input_ingredients:
		#print(ingredient)
		quality_avg += ingredient.quality
	quality_avg = quality_avg/len(input_ingredients)
	finish(quality_avg)
	
func set_ingredient_image(ingredient: Item) -> void:
	if ingredient and ingredient_image_display:
		ingredient_image_display.texture = ingredient.texture # Set the texture of the ingredient
		ingredient_image_display.visible = true # Ensure the image is visible
	else:
		ingredient_image_display.visible = false # Hide the display if no ingredient is provided
