extends Control

signal complete(success: bool)

@onready var inner_circle = $InnerCircle  # Draggable circle.
@onready var timer_label = $TimerLabel  # Displays time left.
@onready var feedback_label = $FeedbackLabel  # Shows feedback messages.
@onready var sfx_boil_loop: AudioStreamPlayer2D = $SFX_BoilLoop
@onready var sfx_boil_init: AudioStreamPlayer2D = $SFX_BoilInit

@onready var selected_food_list: CenterContainer = $"../SelectedFoodList"
@onready var inventory_select_list: CenterContainer = $"../InventorySelectList"
@onready var start_button: TextureButton = $"../StartButton"

@onready var drag_boundary: Area2D = $DragBoundary  # New boundary area.
@onready var boundary_radius: float = ($DragBoundary/CollisionShape2D).shape.radius  # Get boundary radius.
@onready var stew_base: Sprite2D = $StewBase  # Sprite2D to rotate (StewBase).

var required_speed = 2.0  # Minimum velocity required.
var stirring_speed = 0.0  # Current speed of stirring.
var rotation_speed = 0.0  # Rotation speed of the stew base (adjustable).
var target_rotation_speed = 0.0  # Target rotation speed for smooth lerp.
var is_playing = false
var elapsed_time = 0.0  # Tracks valid stirring time.

var initial_inner_circle_position: Vector2  # To store the editor-defined position of the inner circle.
var is_dragging = false  # Tracks whether the user is dragging the circle.

var selected_ingredient = Item  # To store the passed ingredients

func _ready() -> void:
	sfx_boil_init.play()
	initial_inner_circle_position = inner_circle.position
	reset_game()

func reset_game() -> void:
	inner_circle.position = initial_inner_circle_position
	stirring_speed = 0.0
	rotation_speed = 0.0  # Reset rotation speed
	target_rotation_speed = 0.0  # Reset target speed
	elapsed_time = 0.0
	timer_label.text = "Time Left: 5.0"
	feedback_label.text = ""
	feedback_label.modulate = Color(1, 1, 1)  # Reset to white.
	is_playing = false
	is_dragging = false

func start(ingredient: Item) -> void:
	reset_game()
	is_playing = true
	sfx_boil_loop.play()
	selected_food_list.visible = false
	inventory_select_list.visible = false
	start_button.visible = false
	selected_ingredient = ingredient

func _process(delta: float) -> void:
	if not is_playing:
		return

	# Gradually apply the rotation speed to the stew base (counter-clockwise)
	stew_base.rotation += -rotation_speed * delta  # Negative for counter-clockwise rotation

	# Slowly decrease stirring speed when not moving
	if stirring_speed < required_speed:
		feedback_label.text = "Speed Too Low!"
		feedback_label.modulate = Color(1, 0, 0)  # Red text.
		elapsed_time = max(elapsed_time - delta, 0)  # Slowly decrease progress.
		# Decrease rotation speed gradually when stirring speed is too low
		target_rotation_speed = lerp(target_rotation_speed, 0.0, 0.2)
	else:
		feedback_label.text = "Keep Stirring!"
		feedback_label.modulate = Color(0, 1, 0)  # Green text.
		elapsed_time += delta
		# Increase rotation speed gradually when stirring speed is sufficient
		target_rotation_speed = lerp(target_rotation_speed, stirring_speed * 0.5, 0.2)

	# Gradually adjust the current rotation speed to the target rotation speed (smooth acceleration/deceleration)
	rotation_speed = lerp(rotation_speed, target_rotation_speed, 0.2)

	var time_left = max(5.0 - elapsed_time, 0)
	timer_label.text = "Time Left: " + str(round(time_left * 10) / 10.0)

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
				if is_mouse_over_sprite(inner_circle, event.position):
					is_dragging = true
			else:
				is_dragging = false
				inner_circle.position = initial_inner_circle_position
				stirring_speed = 0.0

	if event is InputEventMouseMotion and is_dragging:
		handle_drag(event)

func handle_drag(event: InputEventMouseMotion):
	inner_circle.position += event.relative

	# Get the center of the boundary in local space
	var center_position = drag_boundary.position

	# Clamp movement within the circular boundary
	if inner_circle.position.distance_to(center_position) > boundary_radius:
		var direction = (inner_circle.position - center_position).normalized()
		inner_circle.position = center_position + direction * boundary_radius

	# Calculate stirring speed based on the distance moved
	stirring_speed = event.relative.length()

func is_mouse_over_sprite(sprite: Sprite2D, mouse_position: Vector2) -> bool:
	var texture_size = sprite.texture.get_size()
	var global_position = sprite.global_position
	var rect_min = global_position - (texture_size * sprite.scale) / 2
	var rect_max = global_position + (texture_size * sprite.scale) / 2
	return mouse_position.x >= rect_min.x and mouse_position.x <= rect_max.x and mouse_position.y >= rect_min.y and mouse_position.y <= rect_max.y
