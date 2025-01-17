extends Control

signal complete(output)

@onready var progress_bar: ProgressBar = $ProgressBar

# Settings for the minigame
@export var perfect_leniency = 5  # Precision needed for a "Perfect Chop"
@export var okay_leniency = 15   # Wider range for an "Okay Chop"
@export var target = 100         # Total chop progress required to finish
@export var speed = 100          # Speed of the marker movement (pixels/sec)
@export var perfect_progress = 10  # Progress added for a perfect chop
@export var okay_progress = 5      # Progress added for an okay chop

var chop_progress = 0  # Total progress achieved so far
var playing = false
var moving_right = true  # Direction of the marker movement

func _ready() -> void:
	reset_game()

func start() -> void:
	playing = true

func _process(delta: float) -> void:
	if playing:
		move_marker(delta)
		if Input.is_action_just_pressed("roll"):
			check_chop()

func move_marker(delta: float) -> void:
	# Oscillate the marker (progress bar value) back and forth
	if moving_right:
		progress_bar.value += speed * delta
		if progress_bar.value >= 100:
			progress_bar.value = 100
			moving_right = false
	else:
		progress_bar.value -= speed * delta
		if progress_bar.value <= 0:
			progress_bar.value = 0
			moving_right = true

func check_chop() -> void:
	# Check where the chop lands
	var middle = 50  # Center of the progress bar
	if (progress_bar.value > middle - perfect_leniency) and (progress_bar.value < middle + perfect_leniency):
		# Perfect chop
		chop_progress += perfect_progress
		print("Perfect chop! Progress:", chop_progress)
	elif (progress_bar.value > middle - okay_leniency) and (progress_bar.value < middle + okay_leniency):
		# Okay chop
		chop_progress += okay_progress
		print("Okay chop! Progress:", chop_progress)
	else:
		# Missed chop
		print("Missed the chop!")

	# Check if the player has completed the target progress
	if chop_progress >= target:
		finish()

func reset_game() -> void:
	# Reset game state
	progress_bar.value = 0
	moving_right = true
	chop_progress = 0
	playing = false

func finish() -> void:
	playing = false
	print("Chopping Finished! You completed the task!")
	complete.emit(chop_progress)
