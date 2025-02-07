extends Control

signal complete(success: bool)

@onready var outer_circle = $OuterCircle  # Stationary circle.
@onready var inner_circle = $InnerCircle  # Draggable circle.
@onready var timer_label = $TimerLabel  # Displays time left.
@onready var feedback_label = $FeedbackLabel  # Shows feedback messages.
@onready var sfx_boil_loop: AudioStreamPlayer2D = $SFX_BoilLoop
@onready var sfx_boil_init: AudioStreamPlayer2D = $SFX_BoilInit

var required_speed = 2.0  # Minimum velocity required.
var stirring_speed = 0.0  # Current speed of stirring.
var is_playing = false
var elapsed_time = 0.0  # Tracks valid stirring time.

var initial_inner_circle_position: Vector2  # To store the editor-defined position of the inner circle.
var is_dragging = false  # Tracks whether the user is dragging the circle.

func _ready() -> void:
	# Store the position of the inner circle as defined in the editor.
	sfx_boil_init.play()
	initial_inner_circle_position = inner_circle.position
	reset_game()
	

func reset_game() -> void:
	# Reset the inner circle to its original editor-defined position.
	inner_circle.position = initial_inner_circle_position
	stirring_speed = 0.0
	elapsed_time = 0.0
	timer_label.text = "Time Left: 5.0"
	feedback_label.text = ""
	feedback_label.modulate = Color(1, 1, 1)  # Reset to white.
	is_playing = false
	is_dragging = false

func start() -> void:
	reset_game()
	is_playing = true
	sfx_boil_loop.play()
	

func _process(delta: float) -> void:
	if not is_playing:
		return

	# Check if stirring speed is valid.
	if stirring_speed < required_speed:
		feedback_label.text = "Speed Too Low!"
		feedback_label.modulate = Color(1, 0, 0)  # Red text.
		elapsed_time = max(elapsed_time - delta, 0)  # Slowly decrease progress.
	else:
		feedback_label.text = "Keep Stirring!"
		feedback_label.modulate = Color(0, 1, 0)  # Green text.
		elapsed_time += delta

	# Calculate time left.
	var time_left = max(5.0 - elapsed_time, 0)

	# Update timer display with one decimal place.
	timer_label.text = "Time Left: " + str(round(time_left * 10) / 10.0)

	# Check for game completion.
	if elapsed_time >= 5.0:
		is_playing = false
		timer_label.text = "Time Left: 0.0"
		feedback_label.text = "Success!"
		feedback_label.modulate = Color(0, 1, 0)  # Green text for success.
		finish()

func finish() -> void:
	print("Cooking Finished!")
	complete.emit()

func _input(event: InputEvent) -> void:
	if not is_playing:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Check if the click is on the inner circle.
				if is_mouse_over_sprite(inner_circle, event.position):
					is_dragging = true
			else:
				# Stop dragging when the left button is released.
				is_dragging = false
				inner_circle.position = initial_inner_circle_position
				stirring_speed = 0.0

	if event is InputEventMouseMotion and is_dragging:
		# Drag the inner circle only if the user is holding the mouse button.
		handle_drag(event)

func handle_drag(event: InputEventMouseMotion):
	# Drag the inner circle.
	inner_circle.position += event.relative

	# Clamp the inner circle to the outer circle's radius.
	var max_radius = outer_circle.texture.get_size().x / 2
	if inner_circle.position.distance_to(outer_circle.position) > max_radius:
		var direction = (inner_circle.position - outer_circle.position).normalized()
		inner_circle.position = outer_circle.position + direction * max_radius

	# Calculate stirring speed based on distance moved.
	stirring_speed = event.relative.length()

func is_mouse_over_sprite(sprite: Sprite2D, mouse_position: Vector2) -> bool:
	var texture_size = sprite.texture.get_size()
	var global_position = sprite.global_position
	var rect_min = global_position - (texture_size * sprite.scale) / 2
	var rect_max = global_position + (texture_size * sprite.scale) / 2
	return mouse_position.x >= rect_min.x and mouse_position.x <= rect_max.x and mouse_position.y >= rect_min.y and mouse_position.y <= rect_max.y
