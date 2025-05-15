extends CookingActivity

@onready var marker: TextureRect = $Boundary/Marker  # Marker is now a child of Boundary
@onready var result_label: Label = $ResultLabel
@onready var boundary: TextureRect = $Boundary  # Boundary node
@onready var score_bar: ProgressBar = $ScoreBar  # The ProgressBar node

# Settings
@export var perfect_range = 10  # The range (percentage) for the perfect region
@export var okay_range = 40     # The range (percentage) for the okay region
@export var target = 50         # Total chop progress required
@export var speed = 300         # Speed of marker movement (pixels/sec)
@export var perfect_progress = 10  # Progress for perfect chop
@export var okay_progress = 5     # Progress for okay chop

@onready var sfx_chop_randomiser: AudioStreamPlayer2D = $SFX_ChopRandomiser

@onready var ingredient_image_display: TextureRect = $IngredientImageDisplay
@onready var cooking_scene_2: CookingScene = $".."

var chop_progress = 0
var playing = false
var moving_right = true

func _ready() -> void:
	reset_game()

func start(input_ingredients: Array[Ingredient], output_item) -> void:
	print("Starrting game!")
	super(input_ingredients, output_item)
	playing = true
	result_label.text = ""  # Clear result label on start
	set_ingredient_image(cooking_scene_2.ingredient_handler.selected_ingredients[0])

func set_ingredient_image(ingredient: Item) -> void:
	if ingredient and ingredient_image_display:
		ingredient_image_display.texture = ingredient.texture  # Set the texture of the ingredient
		ingredient_image_display.visible = true  # Ensure the image is visible
	else:
		ingredient_image_display.visible = false  # Hide the display if no ingredient is provided

func reset_marker_position() -> void:
	# Center the marker inside the boundary
	var boundary_pos = boundary.position
	var boundary_width = boundary.size.x
	# Position marker in the middle of the boundary (local coordinates)
	marker.position.x = (boundary_width - marker.size.x) / 2  # Center marker within boundary width

func _process(delta: float) -> void:
	if playing:
		move_marker(delta)
		if Input.is_action_just_pressed("roll"):
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

	# Define the perfect and okay ranges based on percentages
	var perfect_left = 50 - (perfect_range / 2)
	var perfect_right = 50 + (perfect_range / 2)
	var okay_left = 50 - (okay_range / 2)
	var okay_right = 50 + (okay_range / 2)

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
		finish()

func modulate_ingredient() -> void:
	ingredient_image_display.modulate = Color("red")
	await get_tree().create_timer(0.2).timeout
	ingredient_image_display.modulate = Color("white")

func reset_game() -> void:
	# Align marker to the start of the chopping track
	reset_marker_position()  # Center marker inside the boundary
	chop_progress = 0
	playing = false
	if score_bar:
		score_bar.value = 0  # Reset the progress bar to 0
	result_label.text = ""

func finish() -> void:
	playing = false
	result_label.text = "You Win!"
	result_label.modulate = Color(0, 1, 1)  # Cyan
	complete.emit()
