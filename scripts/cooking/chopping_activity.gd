extends CookingActivity

@onready var marker: TextureRect = $Boundary/Marker # Marker is now a child of Boundary
@onready var TESTING_HB := $Boundary/ColorRect
@onready var result_label: Label = $ResultLabel
@onready var boundary: TextureRect = $Boundary # Boundary node
@onready var score_bar: ProgressBar = $ScoreBar # The ProgressBar node
@onready var chopping_track: ChoppingTrack = $ChoppingTrack

@onready var sfx_chop_randomiser: AudioStreamPlayer2D = $SFX_ChopRandomiser
@onready var ingredient_image_display: TextureRect = $IngredientImageDisplay

# Settings
@export var chopping_settings: Array[ChoppingBoardSettings]
@export var force_selected: bool = false ## When true, the selected setting in the editor WILL be select
@export var chopping_setting: ChoppingBoardSettings

enum ACCURACY_SCORES {
	PERFECT = 0,
	OKAY = 1,
	MISSED = 2
}

var chop_progress = 0
var playing = false
var moving_right = true
var chop_table: Array = [0, 0, 0] # Array indicating how many of each chop quality

# Define the perfect and okay ranges based on percentages
var perfect_left
var perfect_right
var okay_left
var okay_right
var target # Total chop progress required
var speed # Speed of marker movement (pixels/sec)
var perfect_progress # Progress for perfect chop
var okay_progress # Progress for okay chop

func _ready() -> void:
	if !chopping_setting:
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
		if marker_pos.x + marker.size.x * marker.scale.x >= boundary_width:
			marker_pos.x = boundary_width - marker.size.x * marker.scale.x
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
	var marker_percentage = ((marker.position.x + marker.size.x/2) / boundary.size.x) * 100
	#print("Marker position: %f%%" % marker_percentage)  # Only print when the button is pressed
	#TESTING_HB.position = Vector2(marker.position.x + marker.size.x/2, TESTING_HB.position.y) # THIS WAS FOR DEBUGGING
	# Check if the marker's percentage is in the perfect, okay, or fail region
	if marker_percentage >= perfect_left and marker_percentage <= perfect_right:
		# Perfect chop
		chop_progress += perfect_progress
		result_label.text = "Perfect!"
		result_label.modulate = Color("#6BDE77") # Green
		sfx_chop_randomiser.play()
		modulate_ingredient()
		chop_table[ACCURACY_SCORES.PERFECT] += 1
	elif marker_percentage >= okay_left and marker_percentage <= okay_right:
		# Okay chop
		chop_progress += okay_progress
		result_label.text = "Okay!"
		result_label.modulate = Color(1, 1, 0) # Yellow
		sfx_chop_randomiser.play()
		modulate_ingredient()
		chop_table[ACCURACY_SCORES.OKAY] += 1
	else:
		# Missed chop
		result_label.text = "Missed!"
		result_label.modulate = Color("#E75757") # Red
		chop_table[ACCURACY_SCORES.MISSED] += 1

	# Update the ProgressBar value as a percentage
	var chop_percentage = (float(chop_progress) / float(target)) * 100 # Calculate the percentage
	if score_bar:
		score_bar.value = chop_percentage # Update progress bar value directly

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
	result_label.text = "Game Complete!"
	result_label.modulate = Color(0, 1, 1) # Cyan
	var quality: Item.Quality = _evaluate_chopping_quality()
	
	await get_tree().create_timer(2.0).timeout
	
	finish(quality)

func _evaluate_chopping_quality() -> Item.Quality:
	var total_data_points = 0
	
	# If more PERFECT than the others
	if chop_table[ACCURACY_SCORES.PERFECT] - chop_table[ACCURACY_SCORES.OKAY] - chop_table[ACCURACY_SCORES.MISSED] > 0:
		return Item.Quality.PERFECT
	# If more OKAY than the others
	elif chop_table[ACCURACY_SCORES.OKAY] - chop_table[ACCURACY_SCORES.PERFECT] - chop_table[ACCURACY_SCORES.MISSED] > 0:
		return Item.Quality.GOOD
	# If more MISSED than the others
	else:
		return Item.Quality.POOR
	
## Set some ingredient to display while chopping
func _set_ingredient_image() -> void:
	# TODO: Make this more logical - random ingredient to chop makes not much sense
	# Grab a random Ingredient from the list of input ingredients
	if !input_ingredients or len(input_ingredients) < 1:
		push_warning("No input ingredient by default")
		return
		
	var ingredient = input_ingredients[randi() % input_ingredients.size()]
	
	if ingredient and ingredient_image_display:
		ingredient_image_display.texture = ingredient.texture # Set the texture of the ingredient
		ingredient_image_display.visible = true # Ensure the image is visible
	else:
		ingredient_image_display.visible = false # Hide the display if no ingredient is provided

func _initialize_marker_position() -> void:
	# Center the marker inside the boundary
	var boundary_width = boundary.size.x
	# Position marker in the middle of the boundary (local coordinates)
	marker.position.x = (boundary_width - marker.size.x) / 2 # Center marker within boundary width

func _determine_chopping_settings() -> void:
	_determine_chop_settings_aux()
	# TODO: Make more robust, calculating the perfect left and right like this is not safe
	# TODO: Convert to a @tool so can easily test visually
	perfect_left = 50 - (chopping_setting.perfect_range / 2)
	perfect_right = 50 + (chopping_setting.perfect_range / 2)
	okay_left = 50 - (chopping_setting.okay_range / 2)
	okay_right = 50 + (chopping_setting.okay_range / 2)
	target = chopping_setting.target
	speed = chopping_setting.speed
	perfect_progress = chopping_setting.perfect_progress
	okay_progress = chopping_setting.okay_progress
	chopping_track.set_ranges(chopping_setting)

func _determine_chop_settings_aux() -> void:
	if force_selected:
		return
	
	# Picks one resource from the given array with a probability inversely proportional to its difficulty. Method from ChatGPT.
	var weights = []         # This will store the calculated weights for each resource
	var total_weight = 0.0   # Sum of all weights, used for normalizing selection
	
	# Step 1: Calculate weights based on 1 / difficulty
	for res in chopping_settings:
		# Prevent division by zero in case difficulty is 0 or missing
		var difficulty = max(res.difficulty, 0.0001)
		var weight = 1.0 / difficulty
		
		weights.append(weight)       # Store this resource's weight
		total_weight += weight       # Add to the running total of weights
	
	# Step 2: Generate a random number between 0 and total_weight
	var rand = randf() * total_weight
	var cumulative = 0.0  # This will track the cumulative weight as we iterate
	
	# Step 3: Iterate through oven_tracing_lines and select the one where the random value falls
	for i in chopping_settings.size():
		cumulative += weights[i]
		if rand <= cumulative:
			# We've found the selected resource
			chopping_setting =  chopping_settings[i]
			return
	
	# Step 4: Fallback in case of rounding error (shouldn't normally happen)
	chopping_setting = chopping_settings[-1]  # Return the last resource as a fallback
	
