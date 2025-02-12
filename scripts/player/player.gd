extends CharacterBody2D

signal activity_interact(activity)
signal death

var can_move: bool = true

# ----- MOVEMENT VARS -----
# For smoother movement
const CROUCH_SPEED : int = 100
const CROUCH_ACCEL : int = 10
const STAND_SPEED : int = 400
const STAND_ACCEL : int = 40
const RUN_SPEED : int = 600
const RUN_ACCEL : int = 50

var curr_speed : float = STAND_SPEED
var curr_accel : float = STAND_ACCEL

var direction : Vector2
var is_moving : bool

# roll_timer affects speed over the course of the roll
const ROLL_SPEED : int = 500
const ROLL_DURATION : float = 0.5
var roll_timer : float = 0

# Roll cooldown
# TODO: Integrate cooldown into statechart
const ROLL_COOLDOWN : float = 0
var roll_cd_timer : float = 0
var can_roll : bool = true

# ----- Node References ----- 
@onready var interact_radius: Area2D = $InteractRadius
@onready var rifle: Node2D = $Rifle
@onready var statechart: StateChart = $StateChart

# ----- Player Stats -----
@export var max_health = 50
var health = max_health:
	set(value):
		health = value
		if health <= 0:
			die()
		Globals.player_ui.update_health(health, max_health)

func _ready() -> void:
	Globals.player = self

func _process(_delta: float) -> void:
	# Code for item pickup
	if (interact_radius.has_overlapping_areas()):
		if (Input.is_action_just_pressed("interact")):
			var area = interact_radius.get_overlapping_areas()[0]
			if area.is_in_group("Item"):
				var item = area.get_parent()
				Inventory_Global.add_item(item.item, item.amount)
				item.delete_item()
			elif area.is_in_group("Workbench"):
				var workbench = area.get_parent()
				activity_interact.emit(workbench.activity)
			elif area.is_in_group("Interactables"):
				var interactable = area.get_parent()
				interactable.interact()
			
	if (Input.is_action_just_pressed("inventory")):
		pass
		
	if (is_moving and curr_speed > CROUCH_SPEED):
		rifle.inaccuracy += 0.05
	else:
		rifle.inaccuracy -= 0.025

func _physics_process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	pass
	
func die() -> void:
	can_move = false
	death.emit()

### BASIC MOVEMENTS (Idle, Crouching, Walking, Running, NOT Rolling) ###

# Events (holding down keys)
func _on_basic_state_physics_processing(delta: float) -> void:
	direction = Input.get_vector("left", "right", "up", "down")
	velocity.x = move_toward(velocity.x, curr_speed * direction.x, curr_accel)
	velocity.y = move_toward(velocity.y, curr_speed * direction.y, curr_accel)
	move_and_slide()
	
	### State Chart ###
	
	is_moving = velocity.length_squared() >= 0.005
	
	# Handle Motion State
	if not is_moving: # To Idle
		statechart.send_event("wasd_release") # Sprint to Idle, Walk to Idle
	else: # To Walk
		statechart.send_event("wasd_hold") # Idle To Walk
	
	# Handle Basic State
	if Input.is_action_pressed("sprint") and is_moving:
		statechart.send_event("shift_hold") # Stance to Sprint
	if Input.is_action_just_released("sprint"):
		statechart.send_event("shift_release") # Sprint To Walk
	
	# Roll cooldown
	if not can_roll:
		roll_cd_timer += delta
		if roll_cd_timer >= ROLL_COOLDOWN:
			can_roll = true
	
	# Handle Aim State
	if Input.is_action_pressed("aim"):
		statechart.send_event("enter_aiming_mode")
	if Input.is_action_just_released("aim"):
		statechart.send_event("exit_aiming_mode")




# Polling (single key presses)
func _on_basic_state_input(event: InputEvent) -> void:
	# Rolling supercedes all states
	if event.is_action_pressed("roll") and can_roll:
		statechart.send_event("space_press")
	if event.is_action_pressed("crouch"):
		statechart.send_event("ctrl_press") # Crouch <-> Standing


### Rolling ###

# roll_timer affects speed over the course of the roll

func _on_roll_state_entered() -> void:
	if direction == Vector2.ZERO:
		statechart.send_event("roll_finished")
	
	roll_timer = 0

func _on_roll_state_exited() -> void:
	can_roll = false # For roll cooldown
	roll_cd_timer = 0

func _on_roll_state_physics_processing(delta: float) -> void:
	roll_timer += delta
	
	if roll_timer >= ROLL_DURATION:
		statechart.send_event("roll_finished")
	else:
		curr_speed = roll_speed(roll_timer)
		velocity = direction * curr_speed
		move_and_slide()

# Quadratic curve starting at ROLL_SPEED and ending at CROUCH_SPEED
func roll_speed(elapsed_time : float) -> float:
	var t : float = elapsed_time / ROLL_DURATION
	return ROLL_SPEED - (ROLL_SPEED - CROUCH_SPEED) * t * t


func _on_aiming_state_entered() -> void:
	rifle.enter_aiming_mode()

func _on_aiming_state_exited() -> void:
	rifle.exit_aiming_mode()
