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

var dash_attack_vector: Vector2 # Position of player when winding up
var dash_attack_speed: float = 1000

var dash_attack_timer: float = 0
var dash_attack_duration: float = 1

var current_dashes = 0
var num_dashes = 3

var is_flying_attack: bool = false
var search_location: Vector2

var circling_angle = 0

func _process(_delta: float) -> void:
	if not anim_sprite.flip_h and velocity.x > 0.1:
		anim_sprite.flip_h = true
	elif anim_sprite.flip_h and velocity.x < -0.1:
		anim_sprite.flip_h = false


func _on_circling_state_entered() -> void:
	return

# Circling player for certain amount of time, before swoop in for a fly attack
func _on_circling_state_physics_processing(delta: float) -> void:
	if target_creature == null:
		return
	circling_angle += cirling_speed * delta
	var offset = Vector2(cos(circling_angle), sin(circling_angle)) * circling_radius
	var target_position = target_creature.global_position + offset
	var direction = (target_position - global_position).normalized()
	velocity = direction * movement_speed * 3.0
	var distance = global_position.distance_to(target_position)
	if distance > circling_radius:
		statechart.send_event("to_chase")
	move_and_slide()


func _on_wind_up_state_entered() -> void:
	pursuit_effect.play()
	velocity = Vector2.ZERO

func _on_wind_up_state_physics_processing(_delta: float) -> void:
	move_and_slide()

# Get direction to player
func _on_fly_attack_state_entered() -> void:
	is_flying_attack = true
	attack_effect.play()
	dash_attack_timer = 0
	current_dashes += 1
	dash_attack_vector = global_position.direction_to(target_creature.global_position)
	fly_attack_hurtbox.monitoring = true

# Dash to player. Dash speed determined by dash_attack_duration.
func _on_fly_attack_state_physics_processing(delta: float) -> void:
	dash_attack_timer += delta
	if dash_attack_timer >= dash_attack_duration:
		$StateChart.send_event("on_dash_attack_finish")
	else:
		velocity = dash_attack_vector * roll_speed(dash_attack_timer)
		move_and_slide()

# Exit Attack state after dashing 3 times.
func _on_fly_attack_state_exited() -> void:
	is_flying_attack = false
	fly_attack_hurtbox.monitoring = false
	# Exit entire Attack state, go back to Active state
	if current_dashes >= num_dashes:
		statechart.send_event("on_attack_finish")


func roll_speed(elapsed_time: float) -> float:
	var t: float = elapsed_time / dash_attack_duration
	return dash_attack_speed - (dash_attack_speed - passive_speed) * t * t

# Overrides function in BasicEnemy. Checks if this enemy is in the flying attack state.
func _on_chase_radius_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player") and not is_flying_attack:
		last_known_position = target_creature.position
		target_creature = null
		statechart.send_event("to_search") # Triggers To Search


# Pause after fly attack, before return to Chase state
func _on_recover_state_entered() -> void:
	pass # Replace with function body.


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
