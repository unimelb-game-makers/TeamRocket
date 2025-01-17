extends Control

signal complete(output)

@onready var chopping_track: TextureRect = $ChoppingTrack
@onready var marker: TextureRect = $Marker
@onready var score_label: Label = $ScoreLabel
@onready var result_label: Label = $ResultLabel

# Settings
@export var perfect_range = 10  # The range (percentage) for the perfect region (20% of track width)
@export var okay_range = 40     # The range (percentage) for the okay region (40% of track width)
@export var target = 50        # Total chop progress required
@export var speed = 300         # Speed of marker movement (pixels/sec)
@export var perfect_progress = 10  # Progress for perfect chop
@export var okay_progress = 5     # Progress for okay chop

var chop_progress = 0
var playing = false
var moving_right = true

func _ready() -> void:
	reset_game()

func start() -> void:
	playing = true
	result_label.text = ""  # Clear result label on start

func _process(delta: float) -> void:
	if playing:
		move_marker(delta)
		if Input.is_action_just_pressed("roll"):
			check_chop()

func move_marker(delta: float) -> void:
	# Get the bounds of the chopping track
	var track_pos = chopping_track.global_position.x
	var track_width = chopping_track.size.x
	var marker_width = marker.size.x
	var marker_pos = marker.position

	if moving_right:
		marker_pos.x += speed * delta
		if marker_pos.x + marker_width >= track_pos + track_width:
			marker_pos.x = track_pos + track_width - marker_width
			moving_right = false
	else:
		marker_pos.x -= speed * delta
		if marker_pos.x <= track_pos:
			marker_pos.x = track_pos
			moving_right = true

	marker.position = marker_pos
	
	# Debugging: Print marker's position as percentage of chopping track width when button is pressed
func check_chop() -> void:
	# Get the width of the chopping track and the global position
	var track_width = chopping_track.size.x
	var track_pos = chopping_track.global_position.x
	
	# Calculate the marker's position as a percentage of the chopping track width
	var marker_percentage = (marker.position.x - track_pos) / track_width * 100
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
		result_label.modulate = Color(0, 1, 0)  # Green
	elif marker_percentage >= okay_left and marker_percentage <= okay_right:
		# Okay chop
		chop_progress += okay_progress
		result_label.text = "Okay!"
		result_label.modulate = Color(1, 1, 0)  # Yellow
	else:
		# Missed chop
		result_label.text = "Missed!"
		result_label.modulate = Color(1, 0, 0)  # Red

	# Update the ScoreLabel to display the progress as a percentage
	var chop_percentage = (float(chop_progress) / float(target)) * 100  # Calculate the percentage
	score_label.text = "Score: " + str(int(chop_percentage)) + "%"  # Show as a percentage (rounded to integer)

	# Check for win condition
	if chop_progress >= target:
		finish()


func reset_game() -> void:
	# Align marker to the start of the chopping track
	marker.position = chopping_track.global_position + Vector2(0, -marker.size.y / 2)
	moving_right = true
	chop_progress = 0
	playing = false
	score_label.text = "Score: 0"
	result_label.text = ""

func finish() -> void:
	playing = false
	result_label.text = "You Win!"
	result_label.modulate = Color(0, 1, 1)  # Cyan
	complete.emit()
