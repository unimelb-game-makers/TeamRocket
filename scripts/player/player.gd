class_name Player
extends CharacterBody2D

@export var walk_loudness: float = 100
@export var sprint_loudness: float = 250
@export var gun_loudness: float = 2000
signal activity_interact(activity)
signal death
signal channel_complete

var can_move: bool = true

# ----- MOVEMENT VARS -----
# For smoother movement
const CROUCH_SPEED : int = 100
const CROUCH_ACCEL : int = 10
const STAND_SPEED : int = 500
const STAND_ACCEL : int = 40
const RUN_SPEED : int = 800
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

signal death
signal channel_complete
signal sound_created(location, loudness)

const ROLL_SPEED: int = 800
const ROLL_DURATION: float = 0.5
const ROLL_COOLDOWN: float = 0
const WALK_FOOTSTEP_SFX_FREQUENCY = 0.75
const SPRINT_FOOTSTEP_SFX_FREQUENCY = 0.5
const AFTER_HURT_INVULNERABLE_DURATION = 1.0

var can_move: bool = true

# ----- MOVEMENT VARS -----
# For smoother movement
var curr_speed: float
var curr_accel: float
var speed_modifier = 1.0

var direction: Vector2
var is_moving = false
var is_sprinting = false
var is_crouching = false
var is_aiming = false

# roll_timer affects speed over the course of the roll
var roll_timer: float = 0

# Roll cooldown
# TODO: Integrate cooldown into statechart
var roll_cd_timer: float = 0
var can_roll: bool = true

var fired = false
var animation_locked = false

# Status effect
# TODO: Should have a separate system to track
var is_slowed
var is_unable_to_dash
var is_invulnerable_after_hurt = false

# ----- Node References -----
@onready var interact_radius: Area2D = $InteractRadius
@onready var rifle: Node2D = $Rifle
@onready var statechart: StateChart = $StateChart
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var channel_timer: Timer = $ChannelTimer
@onready var channeling_particles: CPUParticles2D = $Particles/ChannelingParticles
@onready var footstep_timer: Timer = $FootstepSoundEffect/FootstepTimer
@onready var footstep_audio: AudioStreamPlayer2D = $FootstepSoundEffect
@onready var enemy_noise_rader: Sprite2D = $EnemyNoiseRadar

@onready var slow_debuff_timer: Timer = $DebuffTimer/SlowDebuffTimer
@onready var invulnerable_after_hurt_timer: Timer = $AfterHurtInvulnerableTimer

func _ready() -> void:
	Globals.player = self
	curr_speed = Globals.player_stats.speed
	curr_accel = Globals.player_stats.accel


func _process(_delta: float) -> void:
	# Code for item pickup
	if (Input.is_action_just_pressed("interact")):
		if (interact_radius.has_overlapping_areas()):
			var area = interact_radius.get_overlapping_areas()[0]
			area.interact()

	if (is_moving and curr_speed > Globals.player_stats.crouch_speed):
		rifle.inaccuracy += 0.05
	else:
		rifle.inaccuracy -= 0.025

	if Input.is_action_just_pressed("channel"):
		channel_timer.start(0)
	elif Input.is_action_just_released("channel") or velocity != Vector2(0, 0):
		channel_timer.stop()

	if (not channel_timer.is_stopped()):
		channeling_particles.emitting = true

	if Input.is_action_just_pressed("reload"):
		rifle.reload()

func damage(value: int):
	if is_invulnerable_after_hurt:
		return
	if value > 0:
		Globals.player_ui.play_damaged_effect(value)
	Globals.player_stats.health = clamp(0, Globals.player_stats.health - value, Globals.player_stats.max_health)
	Globals.player_ui.update_health(Globals.player_stats.health, Globals.player_stats.max_health)
	Globals.inventory_ui.update_character_stats()
	make_player_invulnerable_after_hurt()
	if (Globals.player_stats.health <= 0):
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
	velocity = velocity * speed_modifier
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
	footstep_timer.stop()
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
func roll_speed(elapsed_time: float) -> float:
	var t: float = elapsed_time / ROLL_DURATION
	return ROLL_SPEED - (ROLL_SPEED - Globals.player_stats.crouch_speed) * t * t

func _on_idle_state_entered() -> void:
	footstep_timer.stop()

func _on_walk_state_entered() -> void:
	is_sprinting = false
	footstep_audio.play()
	footstep_timer.start(WALK_FOOTSTEP_SFX_FREQUENCY)
	curr_speed = Globals.player_stats.speed
	curr_accel = Globals.player_stats.accel

func _on_standing_state_entered() -> void:
	enemy_noise_rader.visible = false
	is_crouching = false
	is_sprinting = false
	footstep_audio.play()
	footstep_timer.start(WALK_FOOTSTEP_SFX_FREQUENCY)
	curr_speed = Globals.player_stats.speed
	curr_accel = Globals.player_stats.accel

func _on_run_state_entered() -> void:
	is_sprinting = true
	footstep_audio.play()
	footstep_timer.start(SPRINT_FOOTSTEP_SFX_FREQUENCY)
	curr_speed = Globals.player_stats.run_speed
	curr_accel = Globals.player_stats.run_accel

func _on_crouched_state_entered() -> void:
	enemy_noise_rader.visible = true
	is_crouching = true
	footstep_timer.stop()
	curr_speed = Globals.player_stats.crouch_speed
	curr_accel = Globals.player_stats.crouch_accel

func _on_aiming_state_entered() -> void:
	rifle.enter_aiming_mode()
	aim_mode_enter.emit()
	curr_speed = curr_speed / 2
	is_aiming = true

func _on_aiming_state_exited() -> void:
	rifle.exit_aiming_mode()
	aim_mode_exit.emit()
	curr_speed = curr_speed * 2
	is_aiming = false

func _on_channel_timer_timeout() -> void:
	channel_complete.emit()

# --- State Machine Processing Logic for Animations ---

func _on_unarmed_state_physics_processing(_delta: float) -> void:
	# If x movement > 0 and y movement < x then left/right movement
	# Else if y movement > x then up/down movement
	var animation_speed = curr_speed / (Globals.player_stats.speed)

	if is_crouching:
		if (direction.length() > 0.1):
			handle_direction_anim("crouch", direction, "", animation_speed)
		else:
			handle_animation("crouch_idle")
	else:
		if (direction.length() > 0.1):
			handle_direction_anim("move", direction, "", animation_speed)
		else:
			handle_animation("idle")

func _on_aiming_state_physics_processing(_delta: float) -> void:
	if (direction.length() > 0.1):
		var animation_speed = curr_speed / (Globals.player_stats.speed)
		handle_direction_anim("move", direction, "aim", animation_speed)
	else:
		var mouse_pos = get_global_mouse_position()
		var mouse_direction = (mouse_pos - global_position).normalized()
		if (mouse_direction.length() > 0.1):
			handle_direction_anim("stand", mouse_direction, "aim")

	if Input.is_action_just_pressed("fire"):
		rifle.fire(Globals.player_stats.damage)
		sound_created.emit(global_position, gun_loudness)

func _on_run_state_physics_processing(_delta: float) -> void:
	# Handle Movement Animations (Temp Solution)
	# If x movement > 0 and y movement < x then left/right movement
	# Else if y movement > x then up/down movement
	var animation_speed = curr_speed / (Globals.player_stats.speed)
	if (direction.length() > 0.1):
		handle_direction_anim("move", direction, "run", animation_speed)

func _on_rifle_fired() -> void:
	fired = true
	var mouse_pos = get_global_mouse_position()
	var mouse_direction = (mouse_pos - global_position).normalized()
	handle_direction_anim("shoot", mouse_direction)


# --- Handling Animations ---
func handle_direction_anim(action: String, _direction: Vector2, secondary_action: String = "", speed: float = 1.0):
	if (abs(_direction.x) > abs(_direction.y)):
		if (_direction.x > 0):
			handle_animation(action, "right", secondary_action, speed)
		else:
			handle_animation(action, "left", secondary_action, speed)
	else:
		if (_direction.y > 0):
			handle_animation(action, "down", secondary_action, speed)
		else:
			handle_animation(action, "up", secondary_action, speed)

func handle_animation(action: String, _direction: String = "", secondary_action: String = "", _anim_speed: float = 1.0):
	# Handles animations
	# Input the action, direction and secondary action and the speed of the animation if needed
	# Will automatically scale the player (cuz some of the animations are missized)
	if animation_locked:
		return

	var base_scale: float = 0.12
	var side_scale: float = 1.16
	# Have to scale because specifically the left and right movement for walking is smaller than the other animations
	var sprite_scale = base_scale
	if ((_direction == "left" or _direction == "right") and action == "move" and secondary_action != "run"):
		sprite_scale = base_scale * side_scale

	var anim_array = [action]
	if _direction != "":
		anim_array.append(_direction)
	if secondary_action != "":
		anim_array.append(secondary_action)

	var joined_anim = "_".join(anim_array)
	if not joined_anim in anim_sprite.sprite_frames.get_animation_names():
		return

	if (action == "shoot"):
		animation_locked = true

	anim_sprite.scale = Vector2(sprite_scale, sprite_scale)
	anim_sprite.play(joined_anim)


func make_player_invulnerable_after_hurt():
	is_invulnerable_after_hurt = true
	invulnerable_after_hurt_timer.start(AFTER_HURT_INVULNERABLE_DURATION)
	anim_sprite.self_modulate = Color(1, 1, 1, 0.5)

func _on_anim_sprite_animation_finished() -> void:
	if (anim_sprite.animation.begins_with("shoot")):
		animation_locked = false


func _on_footstep_timer_timeout() -> void:
	footstep_audio.play()
	if is_sprinting:
		sound_created.emit(global_position, sprint_loudness)
	else:
		sound_created.emit(global_position, walk_loudness)


## Debuff
func apply_slow_debuff():
	var slow_debuff_time = 3
	if not is_slowed:
		is_slowed = true
		speed_modifier -= 0.5
		slow_debuff_timer.start(slow_debuff_time)

func remove_slow_debuff():
	if is_slowed:
		speed_modifier += 0.5
		is_slowed = false

func _on_slow_debuff_timer_timeout() -> void:
	remove_slow_debuff()


func _on_after_hurt_invulnerable_timer_timeout() -> void:
	is_invulnerable_after_hurt = false
	anim_sprite.self_modulate = Color(1, 1, 1, 1)
