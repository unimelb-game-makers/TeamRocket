extends CookingActivity

"""
Baking activity
0. Put player cursor on starting point
1. Start count down
2. When count down is zero, starting tracking player accuracy and ticking down the clock
3. If player gets the cursor to the end (essentially tracing the line), game ends - calculate score
4. If player leaves line fully, game ends - fails
5. If count down reaches 0, and player not at end, game ends - fail
"""
@export var oven_tracing_lines: Array[OvenLine]
@export var force_selected: bool = false ## When true, the selected setting in the editor WILL be select
@export var selected_oven_tracing_line_data: OvenLine ## The over tracing line data to use. This is overided during _ready() by default, change force_selected to true to always choose the one placed in here.

@onready var oven_tracing_line: OvenTracingLine = $OvenTracingLine
@onready var player_cursor: Area2D = $PlayerCursor
@onready var countdown_label: Label = $"CountDown"
@onready var time_bar: ProgressBar = $"TimeBar"

var is_playing: bool = false
var remaining_time: float

func _ready() -> void:
	if !oven_tracing_line:
		push_warning("No default settings is set for the oven tracing line") # Not necessary since other parts of the code protects it but is safe to have
	
	if get_tree().current_scene == self or is_initialized: # Runs if it as current scene or was initialized by something else then added to tree
		oven_tracing_line.game_finish.connect(minigame_complete)
		
		_determine_oven_tracing_line()
		
		# Setup the board and player
		oven_tracing_line.initialize_data(selected_oven_tracing_line_data)
		
		time_bar.max_value = selected_oven_tracing_line_data.time_allocated
		time_bar.value = selected_oven_tracing_line_data.time_allocated
		remaining_time = selected_oven_tracing_line_data.time_allocated
		
		player_cursor.position = oven_tracing_line.get_starting_point()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		# Countdown to orient the player before starting
		countdown_label.visible = true
		await run_countdown()
		
		start_game()
	else:
		push_error("Minigame called not as parent and without initializing it with initialize() parent method")

func start_game() -> void:
	
	oven_tracing_line.start_game(player_cursor) # Start tracing line tracking

	is_playing = true
	
func _process(delta):
	if is_playing:
		remaining_time -= delta
		time_bar.value = remaining_time
		if remaining_time <= 0:
			remaining_time = 0
			minigame_complete()

func minigame_complete() -> void:
	is_playing = false
	var accuracy = oven_tracing_line.get_accuracy()
	var timeliness = _evaluate_spent_time()
	# Realign cursor position if reached end for cleanness
	if accuracy > 0:
		player_cursor.position = oven_tracing_line._get_ending_point()
		
	print("Game completed!")
	print("Accuracy Rating: ", accuracy, " | Quickness Rating: ", timeliness)
	
	# Methodology to evaluate final rating
	var final_score: float = 0
	if accuracy == 0 or timeliness == 0:
		print("FAILED MINIGAME")
	else:
		final_score = (accuracy + timeliness) / 2
		print("FINAL SCORE: ", final_score)
		
	var quality: Item.Quality = _convert_score_to_quality(final_score)
	close_minigame(quality)

## Called when the minigame is completed
## To re-enable mouse control for the normal game
## Emit signal of completion
func close_minigame(final_score: Item.Quality) -> void:
	# Undo game restrictions
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# TODO: Do what with the final score over here
	# TODO: Emit finish signal? it doesnt pass any parameters btw.
	finish(final_score)

func _evaluate_spent_time() -> float:
	var time_remaining_percentage = remaining_time/time_bar.max_value * 100
	if time_remaining_percentage >= 50: # Use only half the time
		return 100
	elif time_remaining_percentage >= 30:
		return 60
	elif time_remaining_percentage > 0 :
		return 40
	else:
		return 0

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseMotion:
		if is_playing:
			player_cursor.position = player_cursor.position + event.relative

func run_countdown():
	for i in ['3', '2', '1', 'GO!']:
		countdown_label.text = str(i)
		await get_tree().create_timer(1.0).timeout

	countdown_label.visible = false

func _determine_oven_tracing_line() -> void:
	if force_selected:
		return
	
	# Picks one resource from the given array with a probability inversely proportional to its difficulty. Method from ChatGPT.
	var weights = []         # This will store the calculated weights for each resource
	var total_weight = 0.0   # Sum of all weights, used for normalizing selection
	
	# Step 1: Calculate weights based on 1 / difficulty
	for res in oven_tracing_lines:
		# Prevent division by zero in case difficulty is 0 or missing
		var difficulty = max(res.difficulty, 0.0001)
		var weight = 1.0 / difficulty
		
		weights.append(weight)       # Store this resource's weight
		total_weight += weight       # Add to the running total of weights
	
	# Step 2: Generate a random number between 0 and total_weight
	var rand = randf() * total_weight
	var cumulative = 0.0  # This will track the cumulative weight as we iterate
	
	# Step 3: Iterate through oven_tracing_lines and select the one where the random value falls
	for i in oven_tracing_lines.size():
		cumulative += weights[i]
		if rand <= cumulative:
			# We've found the selected resource
			selected_oven_tracing_line_data =  oven_tracing_lines[i]
			return
	
	# Step 4: Fallback in case of rounding error (shouldn't normally happen)
	selected_oven_tracing_line_data = oven_tracing_lines[-1]  # Return the last resource as a fallback
	
	
func _convert_score_to_quality(final_score: float) -> Item.Quality:
	if final_score < 10.0:
		return Item.Quality.RUINED
	elif final_score < 30.0:
		return Item.Quality.POOR
	elif final_score < 60.0:
		return Item.Quality.NORMAL
	elif final_score < 80.0:
		return Item.Quality.GOOD
	elif final_score < 95.0:
		return Item.Quality.EXCELLENT
	else:
		return Item.Quality.PERFECT
