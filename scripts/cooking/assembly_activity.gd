extends CookingActivity

@onready var ingredient_image_display: TextureRect = $IngredientImageDisplay
@onready var feedback_label: Label = $FeedbackLabel
@onready var cooking_scene: CookingScene = $".."

var playing = false

func reset_game():
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	

func start(input_ingredients: Array[Ingredient], output_item: Item) -> void:
	#super(input_ingredients, output_item)
	feedback_label.text = ("You made " + output_item.item_name)
	set_ingredient_image(output_item)
	playing = true
	await get_tree().create_timer(3).timeout
	complete_minigame()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func complete_minigame() -> void:
	finish(100)
	
func set_ingredient_image(ingredient: Item) -> void:
	if ingredient and ingredient_image_display:
		ingredient_image_display.texture = ingredient.texture # Set the texture of the ingredient
		ingredient_image_display.visible = true # Ensure the image is visible
	else:
		ingredient_image_display.visible = false # Hide the display if no ingredient is provided
