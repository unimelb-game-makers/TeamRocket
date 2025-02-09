extends Control

"""
Baking activity
0. Prepare ingredients
1. Put ingredients in
2. Press space bar with timing to mix
3. Once mixed, put in oven for specified time
4. Player can move away and do other things during this time
5. Player can check on baking or take it out at any point
6. Player must take out baking at perfect time (within a few seconds)
7. Otherwise, baking may be undercooked or overcooked
"""

signal complete(output)


@onready var POT_POS: Vector2 = $Pot.position
@onready var label: Label = $Label


# These track the position of the mouse
var mouse_id: int = 0
var to_mouse_id: int = 0

# The current progress for mixing/baking
var current_progress: float = 0.0
# The time passed since last whatever update
# Mainly used for tracking mixing timing
var current_time_pass: float = 0.0

# These track the current state of the minigame
# playing: true -> Player is currently actively in the minigame screen
# playing: false, baking: true -> player has completed minigame, and is waiting
# playing: false, baking: false -> player either has not started, or is done with everything
var playing: bool = false
var baking: bool = false


func start() -> void:
	playing = true
	current_time_pass = 0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("roll"):
		if playing and !baking:
			if 0.75 <= current_time_pass and current_time_pass <= 1.25:
				current_progress += 1
			else:
				current_progress += 0.5
			if current_progress >= 10:
				baking = true
				playing = false
			current_time_pass = 0
		elif baking:
			if 25 <= current_time_pass and current_time_pass <= 35:
				finish()
			elif current_time_pass < 25:
				print("Too soon!")
			else:
				print("Too late!")
				baking = false
				playing = true


func _process(delta: float) -> void:
	current_time_pass += delta
	label.text = "%.1f: %.2f" % [current_progress, current_time_pass]



func finish() -> void:
	baking = false
	print("Baking Finished!")
	complete.emit()
