class_name Player
extends CharacterBody2D

signal activity_interact(activity)
signal death
signal channel_complete

var can_move: bool = true

# ----- MOVEMENT VARS -----
# For smoother movement
const CROUCH_SPEED : int = 100
const CROUCH_ACCEL : int = 10
const STAND_SPEED : int = 200
const STAND_ACCEL : int = 40
const RUN_SPEED : int = 400
const RUN_ACCEL : int = 50

var curr_speed : float = STAND_SPEED
var curr_accel : float = STAND_ACCEL

var direction : Vector2
var is_moving : bool

# roll_timer affects speed over the course of the roll
const ROLL_SPEED : int = 800
const ROLL_DURATION : float = 0.5
var roll_timer : float = 0

# Roll cooldown
# TODO: Integrate cooldown into statechart
const ROLL_COOLDOWN : float = 0
var roll_cd_timer : float = 0
var can_roll : bool = true


var fired = false

# ----- Node References ----- 
@onready var interact_radius: Area2D = $InteractRadius
@onready var rifle: Node2D = $Rifle
@onready var statechart: StateChart = $StateChart
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var channel_timer: Timer = $ChannelTimer
@onready var channeling_particles: CPUParticles2D = $Particles/ChannelingParticles

# ----- Player Stats -----
@export var max_health = 50
var health = max_health:
	set(value):
		health = value
		if health <= 0:
			die()
		Globals.player_ui.update_health(health, max_health)

# ---- Signals ----
# For camera control
signal aim_mode_enter
signal aim_mode_exit

func _ready() -> void:
	Globals.player = self
	max_health *= 1 + Globals.player_hp_increase

func _process(_delta: float) -> void:
	# Code for item pickup
	if (Input.is_action_just_pressed("interact")):
		if (interact_radius.has_overlapping_areas()):
			var area = interact_radius.get_overlapping_areas()[0]
			area.interact()
		
	if (is_moving and curr_speed > CROUCH_SPEED):
		rifle.inaccuracy += 0.05
	else:
		rifle.inaccuracy -= 0.025
		
	if Input.is_action_just_pressed("channel"):
		channel_timer.start(0)
	elif Input.is_action_just_released("channel") or velocity != Vector2(0,0):
		channel_timer.stop()
	
	if (not channel_timer.is_stopped()):
		channeling_particles.emitting = true

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

func _on_standing_state_entered() -> void:
	curr_speed = STAND_SPEED
	curr_accel = STAND_ACCEL

func _on_run_state_entered() -> void:
	curr_speed = RUN_SPEED
	curr_accel = RUN_ACCEL

func _on_crouched_state_entered() -> void:
	curr_speed = CROUCH_SPEED
	curr_accel = CROUCH_ACCEL

func _on_aiming_state_entered() -> void:
	rifle.enter_aiming_mode()
	aim_mode_enter.emit()
	curr_speed = curr_speed / 2

func _on_aiming_state_exited() -> void:
	rifle.exit_aiming_mode()
	aim_mode_exit.emit()
	curr_speed = curr_speed * 2

func _on_channel_timer_timeout() -> void:
	channel_complete.emit()

# ALL OF THESE ARE TO HANDLE ANIMATIONS: REDO AFTER PROTOTYPE IS DONE

func _on_aiming_state_physics_processing(delta: float) -> void:
	var animation_speed = curr_speed / (STAND_SPEED)
	if (direction.length() > 0.1):
		if (abs(direction.x) > abs(direction.y)):
			animated_sprite_2d.scale = Vector2(0.14, 0.14)
			# Left/Right movement
			if (direction.x > 0):
				animated_sprite_2d.play("move_right", animation_speed)
			else:
				animated_sprite_2d.play("move_left", animation_speed)
		else:
			animated_sprite_2d.scale = Vector2(0.12, 0.12)
			if (direction.y > 0):
				animated_sprite_2d.play("move_down_aim", animation_speed)
			else:
				animated_sprite_2d.play('move_up_aim', animation_speed)
	else:
		var mouse_pos = get_global_mouse_position()
		var mouse_direction = (mouse_pos - global_position).normalized()
		if (mouse_direction.length() > 0.1):
			if (abs(mouse_direction.x) > abs(mouse_direction.y)):
				animated_sprite_2d.scale = Vector2(0.14, 0.14)
				# Left/Right movement
				if (mouse_direction.x > 0):
					animated_sprite_2d.play("move_right", animation_speed)
				else:
					animated_sprite_2d.play("move_left", animation_speed)
			else:
				animated_sprite_2d.scale = Vector2(0.12, 0.12)
				if (mouse_direction.y > 0):
					animated_sprite_2d.play("stand_down_aim", animation_speed)
				else:
					animated_sprite_2d.play('stand_up_aim', animation_speed)

func _on_unarmed_state_physics_processing(delta: float) -> void:
	# Handle Movement Animations (Temp Solution)
	# If x movement > 0 and y movement < x then left/right movement
	# Else if y movement > x then up/down movement
	var animation_speed = curr_speed / (STAND_SPEED)
	if (direction.length() > 0.1):
		if (abs(direction.x) > abs(direction.y)):
			animated_sprite_2d.scale = Vector2(0.14, 0.14)
			# Left/Right movement
			if (direction.x > 0):
				animated_sprite_2d.play("move_right", animation_speed)
			else:
				animated_sprite_2d.play("move_left", animation_speed)
		else:
			animated_sprite_2d.scale = Vector2(0.12, 0.12)
			if (direction.y > 0):
				animated_sprite_2d.play("move_down", animation_speed)
			else:
				animated_sprite_2d.play('move_up', animation_speed)
	else:
		animated_sprite_2d.scale = Vector2(0.12, 0.12)
		animated_sprite_2d.play("idle")

func _on_run_state_physics_processing(delta: float) -> void:
	# Handle Movement Animations (Temp Solution)
	# If x movement > 0 and y movement < x then left/right movement
	# Else if y movement > x then up/down movement
	var animation_speed = curr_speed / (STAND_SPEED)
	if (direction.length() > 0.1):
		if (abs(direction.x) > abs(direction.y)):
			animated_sprite_2d.scale = Vector2(0.14, 0.14)
			# Left/Right movement
			if (direction.x > 0):
				animated_sprite_2d.play("move_right", animation_speed)
			else:
				animated_sprite_2d.play("move_left", animation_speed)
		else:
			animated_sprite_2d.scale = Vector2(0.12, 0.12)
			if (direction.y > 0):
				animated_sprite_2d.play("move_down_run", animation_speed)
			else:
				animated_sprite_2d.play('move_up_run', animation_speed)

func _on_rifle_fired() -> void:
	fired = true
	var mouse_pos = get_global_mouse_position()
	var mouse_direction = (mouse_pos - global_position).normalized()
	if (mouse_direction.length() > 0.1):
		if (abs(mouse_direction.x) > abs(mouse_direction.y)):
			animated_sprite_2d.scale = Vector2(0.14, 0.14)
			# Left/Right movement
			if (mouse_direction.x > 0):
				animated_sprite_2d.play("move_right")
			else:
				animated_sprite_2d.play("move_left")
		else:
			animated_sprite_2d.scale = Vector2(0.12, 0.12)
			if (mouse_direction.y > 0):
				animated_sprite_2d.play("shoot_down")
			else:
				animated_sprite_2d.play('shoot_up')
