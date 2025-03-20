class_name Player
extends CharacterBody2D

signal activity_interact(activity)
signal death
signal channel_complete

var can_move: bool = true

@export var player_stats: PlayerStatsResource

# ----- MOVEMENT VARS -----
# For smoother movement
var curr_speed : float
var curr_accel : float

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
var animation_locked = false

# ----- Node References -----
@onready var interact_radius: Area2D = $InteractRadius
@onready var rifle: Node2D = $Rifle
@onready var statechart: StateChart = $StateChart
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var channel_timer: Timer = $ChannelTimer
@onready var channeling_particles: CPUParticles2D = $Particles/ChannelingParticles

# ----- Player Stats -----

# ---- Signals ----
# For camera control
signal aim_mode_enter
signal aim_mode_exit

func _ready() -> void:
	Globals.player = self
	curr_speed = player_stats.speed
	curr_accel = player_stats.accel
	player_stats.health = player_stats.max_health

func _process(_delta: float) -> void:
	# Code for item pickup
	if (Input.is_action_just_pressed("interact")):
		if (interact_radius.has_overlapping_areas()):
			var area = interact_radius.get_overlapping_areas()[0]
			area.interact()

	if (is_moving and curr_speed > player_stats.crouch_speed):
		rifle.inaccuracy += 0.05
	else:
		rifle.inaccuracy -= 0.025

	if Input.is_action_just_pressed("channel"):
		channel_timer.start(0)
	elif Input.is_action_just_released("channel") or velocity != Vector2(0,0):
		channel_timer.stop()

	if (not channel_timer.is_stopped()):
		channeling_particles.emitting = true
		
	if Input.is_action_just_pressed("reload"):
		rifle.reload()

func damage(value: int):
	player_stats.health -= value
	Globals.player_ui.update_health(player_stats.health, player_stats.max_health)
	if (player_stats.health < 0):
		die()

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
	return ROLL_SPEED - (ROLL_SPEED - player_stats.crouch_speed) * t * t

func _on_standing_state_entered() -> void:
	curr_speed = player_stats.speed
	curr_accel = player_stats.accel

func _on_run_state_entered() -> void:
	curr_speed = player_stats.run_speed
	curr_accel = player_stats.run_accel

func _on_crouched_state_entered() -> void:
	curr_speed = player_stats.crouch_speed
	curr_accel = player_stats.crouch_accel

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

# --- State Machine Processing Logic for Animations ---

func _on_unarmed_state_physics_processing(delta: float) -> void:
	# If x movement > 0 and y movement < x then left/right movement
	# Else if y movement > x then up/down movement
	var animation_speed = curr_speed / (player_stats.speed)
	if (direction.length() > 0.1):
		handle_direction_anim("move", direction, "", animation_speed)
	else:
		handle_animation("idle")

func _on_aiming_state_physics_processing(delta: float) -> void:
	if (direction.length() > 0.1):
		var animation_speed = curr_speed / (player_stats.speed)
		handle_direction_anim("move", direction, "aim", animation_speed)
	else:
		var mouse_pos = get_global_mouse_position()
		var mouse_direction = (mouse_pos - global_position).normalized()
		if (mouse_direction.length() > 0.1):
			handle_direction_anim("stand", mouse_direction, "aim")
			
	if Input.is_action_just_pressed("fire"):
		rifle.fire(player_stats.damage)

func _on_run_state_physics_processing(delta: float) -> void:
	# Handle Movement Animations (Temp Solution)
	# If x movement > 0 and y movement < x then left/right movement
	# Else if y movement > x then up/down movement
	var animation_speed = curr_speed / (player_stats.speed)
	if (direction.length() > 0.1):
		handle_direction_anim("move", direction, "run", animation_speed)

func _on_rifle_fired() -> void:
	fired = true
	var mouse_pos = get_global_mouse_position()
	var mouse_direction = (mouse_pos - global_position).normalized()
	handle_direction_anim("shoot", mouse_direction)


# --- Handling Animations ---

func handle_direction_anim(action: String, direction: Vector2, secondary_action: String = "", speed: float = 1.0):
	if (abs(direction.x) > abs(direction.y)):
		if (direction.x > 0):
			handle_animation(action, "right", secondary_action, speed)
		else:
			handle_animation(action, "left", secondary_action, speed)
	else:
		if (direction.y > 0):
			handle_animation(action, "down", secondary_action, speed)
		else:
			handle_animation(action, "up", secondary_action, speed)

func handle_animation(action: String, direction: String = "", secondary_action: String = "", anim_speed: float = 1.0):
	# Handles animations
	# Input the action, direction and secondary action and the speed of the animation if needed
	# Will automatically scale the player (cuz some of the animations are missized)
	
	if animation_locked:
		return 
	
	var base_scale: float = 0.12
	var side_scale: float = 1.16
	# Have to scale because specifically the left and right movement for walking is smaller than the other animations
	var sprite_scale = base_scale
	if ((direction == "left" or direction == "right") and action == "move" and secondary_action != "run"):
		sprite_scale = base_scale * side_scale
	
	var anim_array = [action]
	if direction != "": anim_array.append(direction)
	if secondary_action != "": anim_array.append(secondary_action)
	
	var joined_anim = "_".join(anim_array)
	if not joined_anim in animated_sprite_2d.sprite_frames.get_animation_names():
		return
	
	if (action == "shoot"):
		animation_locked = true
	
	animated_sprite_2d.scale = Vector2(sprite_scale, sprite_scale)
	animated_sprite_2d.play(joined_anim)

func _on_animated_sprite_2d_animation_finished() -> void:
	if (animated_sprite_2d.animation.begins_with("shoot")):
		animation_locked = false
