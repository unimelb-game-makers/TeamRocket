extends BasicEnemy


## Due to velocity and physics, actual radius would be around 65% of this value
@export var circling_radius: float = 1000
## In radians per second
@export var cirling_speed: float = 1.0
@export var circling_time: float = 3

@onready var idle_effect: AudioStreamPlayer2D = $SoundEffects/IdleEffect
@onready var attack_effect: AudioStreamPlayer2D = $SoundEffects/AttackEffect
@onready var pursuit_effect: AudioStreamPlayer2D = $SoundEffects/PursuitEffect
@onready var hunt_effect: AudioStreamPlayer2D = $SoundEffects/HuntEffect
@onready var hurt_effect: AudioStreamPlayer2D = $SoundEffects/HurtEffect

@onready var fly_attack_hurtbox: Area2D = $FlyAttackHurtbox
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var circling_attack_timer: Timer = $CirclingAttackTimer

# Use these coeffcient to check whether circling or chase to make it smoother
# than just use circling_radius directly (give the raven some leeway)
const CIRCLING_RADIUS_COEFFICIENT_TO_CHASE = 1.35
const CIRCLING_RADIUS_COEFFICIENT_TO_ATTACK = 0.65

## Position of player when winding up
var fly_attack_vector: Vector2
## How far the fly attack can be
var fly_attack_range: float = 2000
var fly_attack_timer: float = 0
var fly_attack_duration: float = 1
var is_flying_attack: bool = false
var search_location: Vector2

var circling_angle = 0

func _process(_delta: float) -> void:
	if not anim_sprite.flip_h and velocity.x > 0.1:
		anim_sprite.flip_h = true
	elif anim_sprite.flip_h and velocity.x < -0.1:
		anim_sprite.flip_h = false

# Circling player for certain amount of time, before swoop in for a fly attack
func _on_circling_state_entered() -> void:
	var rand_time = randf_range(4, 10)
	circling_attack_timer.start(rand_time)

func _on_circling_state_physics_processing(delta: float) -> void:
	if target_creature == null:
		statechart.send_event("to_search")
		return
	var distance = global_position.distance_to(target_creature.global_position)
	if distance > circling_radius * CIRCLING_RADIUS_COEFFICIENT_TO_CHASE:
		statechart.send_event("to_chase")
		return
	circling_angle += cirling_speed * delta
	var offset = Vector2(cos(circling_angle), sin(circling_angle)) * circling_radius
	var target_position = target_creature.global_position + offset
	var direction = (target_position - global_position).normalized()
	velocity = direction * movement_speed * 3.0
	move_and_slide()

func _on_circling_attack_timer_timeout() -> void:
	statechart.send_event("to_fly_attack")


func _on_chase_state_physics_processing(delta: float) -> void:
	if target_creature == null:
		statechart.send_event("to_search")
		return
	var distance = global_position.distance_to(target_creature.global_position)
	if distance < circling_radius * CIRCLING_RADIUS_COEFFICIENT_TO_ATTACK:
		statechart.send_event("to_attack")
		return
	super (delta)


func _on_wind_up_state_entered() -> void:
	pursuit_effect.play()
	velocity = Vector2.ZERO

func _on_wind_up_state_physics_processing(_delta: float) -> void:
	move_and_slide()

# Get direction to player
func _on_fly_attack_state_entered() -> void:
	is_flying_attack = true
	attack_effect.play()
	fly_attack_timer = 0
	fly_attack_vector = global_position.direction_to(target_creature.global_position)
	fly_attack_hurtbox.monitoring = true

# Dash to player. Dash speed determined by fly_attack_duration.
func _on_fly_attack_state_physics_processing(delta: float) -> void:
	fly_attack_timer += delta
	if fly_attack_timer >= fly_attack_duration:
		statechart.send_event("to_recover")
	else:
		velocity = fly_attack_vector * roll_speed(fly_attack_timer)
		move_and_slide()

func _on_fly_attack_state_exited() -> void:
	is_flying_attack = false
	fly_attack_hurtbox.monitoring = false


func roll_speed(elapsed_time: float) -> float:
	var t: float = elapsed_time / fly_attack_duration
	return fly_attack_range - (fly_attack_range - passive_speed) * t * t

func _on_chase_radius_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player") and not is_flying_attack:
		super (area)


# Pause after fly attack, before return to Chase state
func _on_recover_state_entered() -> void:
	velocity = Vector2.ZERO


func _on_passive_state_entered() -> void:
	super ()
	idle_effect.play()

func _on_active_state_entered() -> void:
	super ()
	hunt_effect.play()

func _on_fly_attack_hurtbox_body_entered(body: Node2D) -> void:
	if body is Player:
		body.damage(base_damage)

func damage(value: int):
	super (value)
	hurt_effect.play()
	target_creature = Globals.player
	statechart.send_event("to_chase")
