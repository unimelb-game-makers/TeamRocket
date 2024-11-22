extends Node2D

signal complete(output)

@onready var progress_bar: ProgressBar = $ProgressBar

# Progress bar and how lenient the chopping timing is
@export var target_progress = 50
@export var leniency = 10

# Target chops and amount chopped so far
var chopped = 0
@export var target = 5

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if (progress_bar.value == 100):
		progress_bar.value = 0
	progress_bar.value += 0.05
	
	if (Input.is_action_just_pressed("roll")):
		if (target_progress - leniency < progress_bar.value and progress_bar.value < target_progress + leniency):
			print("Chopped successfully!")
			progress_bar.value = 0
			chopped += 1
			if (chopped >= target):
				finish()
		else:
			print("Chop unsuccessful")
			progress_bar.value = 0

func finish() -> void:
	print("Chopping Finished!")
	complete.emit()
