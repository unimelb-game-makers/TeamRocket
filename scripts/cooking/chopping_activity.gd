extends CookingActivity

@onready var marker: TextureRect = $Boundary/Marker  # Marker is now a child of Boundary
@onready var result_label: Label = $ResultLabel
@onready var boundary: TextureRect = $Boundary  # Boundary node
@onready var score_bar: ProgressBar = $ScoreBar  # The ProgressBar node

@onready var sfx_chop_randomiser: AudioStreamPlayer2D = $SFX_ChopRandomiser
@onready var ingredient_image_display: TextureRect = $IngredientImageDisplay

# Settings
@export var chopping_settings: ChoppingBoardSettings

enum ACCURACY_SCORES {
	PERFECT = 0,
	GOOD = 1,
	FAIL = 2
}

var chop_progress = 0
var playing = false
var moving_right = true
var chop_table: Array = [0,0,0] # Array indicating how many of each chop quality

# Define the perfect and okay ranges based on percentages
var perfect_left
var perfect_right
var okay_left
var okay_right
var target           # Total chop progress required
var speed            # Speed of marker movement (pixels/sec)
var perfect_progress # Progress for perfect chop
var okay_progress    # Progress for okay chop

func _ready() -> void:
	if !chopping_settings:
		push_warning("No default settings is set for chopping board settings") # Not necessary since other parts of the code protects it but is safe to have
	
	if get_tree().current_scene == self or is_initialized: # Runs if it as current scene or was initialized by something else then added to tree
		# Start Chopping game
		_determine_chopping_settings()
		_set_ingredient_image()
		_initialize_marker_position()
		playing = true
		print("Starting game")
		
	else:
		push_error("Minigame called not as parent and without initializing it with initialize() parent method")

func _process(delta: float) -> void:
	if playing:
		move_marker(delta)
		if Input.is_action_just_pressed("roll"): # This is the space button - rolling was for when the player dashes
			check_chop()

func move_marker(delta: float) -> void:
	var boundary_width = boundary.size.x
	var marker_pos = marker.position

	if moving_right:
		marker_pos.x += speed * delta
		# Reverse direction if marker hits the right side of the boundary
		if marker_pos.x + marker.size.x*marker.scale.x >= boundary_width:
			marker_pos.x = boundary_width - marker.size.x*marker.scale.x
			moving_right = false
	else:
		marker_pos.x -= speed * delta
		# Reverse direction if marker hits the left side of the boundary
		if marker_pos.x <= 0:
			marker_pos.x = 0
			moving_right = true

	marker.position = marker_pos

func check_chop() -> void:
	# Calculate marker's local position as a percentage of boundary width
	var marker_percentage = (marker.position.x / boundary.size.x) * 100
	print("Marker position: %f%%" % marker_percentage)  # Only print when the button is pressed

	# Check if the marker's percentage is in the perfect, okay, or fail region
	if marker_percentage >= perfect_left and marker_percentage <= perfect_right:
		# Perfect chop
		chop_progress += perfect_progress
		result_label.text = "Perfect!"
		result_label.modulate = Color("#6BDE77")  # Green
		sfx_chop_randomiser.play()
		modulate_ingredient()
	elif marker_percentage >= okay_left and marker_percentage <= okay_right:
		# Okay chop
		chop_progress += okay_progress
		result_label.text = "Okay!"
		result_label.modulate = Color(1, 1, 0)  # Yellow
		sfx_chop_randomiser.play()
		modulate_ingredient()
	else:
		# Missed chop
		result_label.text = "Missed!"
		result_label.modulate = Color("#E75757")  # Red

	# Update the ProgressBar value as a percentage
	var chop_percentage = (float(chop_progress) / float(target)) * 100  # Calculate the percentage
	if score_bar:
		score_bar.value = chop_percentage  # Update progress bar value directly

	# Check for win condition
	if chop_progress >= target:
		minigame_complete()

## Make the ingredient flash when chopped
func modulate_ingredient() -> void:
	ingredient_image_display.modulate = Color("red")
	await get_tree().create_timer(0.2).timeout
	ingredient_image_display.modulate = Color("white")

func minigame_complete() -> void:
	playing = false
	result_label.text = "You Win!"
	result_label.modulate = Color(0, 1, 1)  # Cyan
	var quality = _evaluate_chopping_quality()
	finish(quality)

func _evaluate_chopping_quality() -> float:
	return 100
	
## Set some ingredient to display while chopping
func _set_ingredient_image() -> void:
	# TODO: Make this more logical - random ingredient to chop makes not much sense
	# Grab a random Ingredient from the list of input ingredients
	if !input_ingredients or len(input_ingredients) < 1:
		push_warning("No input ingredient by default")
		return
		
	var ingredient = input_ingredients[randi() % input_ingredients.size()]
	
	if ingredient and ingredient_image_display:
		ingredient_image_display.texture = ingredient.texture  # Set the texture of the ingredient
		ingredient_image_display.visible = true  # Ensure the image is visible
	else:
		ingredient_image_display.visible = false  # Hide the display if no ingredient is provided

func _initialize_marker_position() -> void:
	# Center the marker inside the boundary
	var boundary_width = boundary.size.x
	# Position marker in the middle of the boundary (local coordinates)
	marker.position.x = (boundary_width - marker.size.x) / 2  # Center marker within boundary width

func _determine_chopping_settings() -> void:
	# TODO: Figure out how to turn input_ingredients and output into a preset map/create in real-time (harder)
	
	# TODO: Make more robust, calculating the perfect left and right like this is not safe
	# TODO: Convert to a @tool so can easily test visually
	perfect_left = 50 - (chopping_settings.perfect_range / 2)
	perfect_right = 50 + (chopping_settings.perfect_range / 2)
	okay_left = 50 - (chopping_settings.okay_range / 2)
	okay_right = 50 + (chopping_settings.okay_range / 2)
	target = chopping_settings.target
	speed = chopping_settings.speed
	perfect_progress = chopping_settings.perfect_progress
	okay_progress = chopping_settings.okay_progress
