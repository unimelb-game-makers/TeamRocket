extends CharacterBody2D

const CROUCH_SPEED = 100
const STAND_SPEED = 200
const RUN_SPEED = 300
@onready var curr_speed

func _ready() -> void:
	curr_speed = STAND_SPEED

func _physics_process(delta: float) -> void:
	
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * curr_speed
	
	move_and_slide()
	
	
	### State Chart ###
	
	# If player runs into a wall, transition to walk state?
	
	var is_moving = velocity.length_squared() >= 0.005
	
	# Handle Motion State
	if not is_moving: # To Idle
		$StateChart.send_event("wasd_release") # Sprint to Idle, Walk to Idle
	else: # To Walk
		$StateChart.send_event("wasd_hold") # Idle To Walk
	
	# Handle Basic State
	if Input.is_action_pressed("sprint") and is_moving:
		$StateChart.send_event("shift_hold") # Stance to Sprint
	if Input.is_action_just_released("sprint"):
		$StateChart.send_event("shift_release") # Sprint To Walk

# For polling
func _input(event: InputEvent) -> void:

	if event.is_action_pressed("roll"): # Not implemented yet
		$StateChart.send_event("roll")
	
	if event.is_action_pressed("crouch"):
		$StateChart.send_event("ctrl_press") # Crouch <-> Standing


func _on_crouched_state_entered() -> void:
	curr_speed = CROUCH_SPEED
	change_size(20)

func _on_standing_state_entered() -> void:
	curr_speed = STAND_SPEED
	change_size(40)

func _on_run_state_entered() -> void:
	curr_speed = RUN_SPEED
	change_size(60)

func change_size(length):
	$ColorRect.size.y = length
	$ColorRect.position.y = -length
