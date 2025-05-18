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

@export var oven_tracing_line_data: OvenLine

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
		
		determine_oven_tracing_line()
		#self.input_ingredients = input_ingredients
		#self.output_item = output_item
		
		# Setup the board and player
		oven_tracing_line.initialize_data(oven_tracing_line_data)
		
		time_bar.max_value = oven_tracing_line_data.time_allocated
		time_bar.value = oven_tracing_line_data.time_allocated
		remaining_time = oven_tracing_line_data.time_allocated
		
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

func determine_oven_tracing_line() -> void:
	# TODO: Determine difficulty of oven tracing line
	pass # Currently it just runs whatever was in the editor
	
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
