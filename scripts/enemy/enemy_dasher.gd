extends BasicEnemy

@export var range_before_dash_attack = 500

@onready var dash_attack_area: Area2D = $DashAttackArea
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

var dash_attack_vector: Vector2 # Position of player when winding up
var dash_attack_range: float = 1000
var dash_attack_timer: float = 0
var dash_attack_duration: float = 1
var current_dashes = 0
var num_dashes = 3
var in_attack_state: bool = false
var search_location: Vector2

func _process(_delta: float) -> void:
	if not anim_sprite.flip_h and velocity.x > 0.1:
		anim_sprite.flip_h = true
	elif anim_sprite.flip_h and velocity.x < -0.1:
		anim_sprite.flip_h = false


func _on_chase_state_physics_processing(delta: float) -> void:
	if target_creature == null:
		statechart.send_event("to_search")
		return
	var distance = global_position.distance_to(target_creature.global_position)
	if distance < range_before_dash_attack:
		statechart.send_event("to_attack")
		return
	super (delta)

# Stop moving, and prepare to dash. Delay to Dash Attack set in Inspector
func _on_wind_up_state_entered() -> void:
	anim_sprite.play("prepare_dash")
	play_sound("pursuit")
	velocity = Vector2.ZERO

func _on_wind_up_state_physics_processing(_delta: float) -> void:
	move_and_slide()

# Get direction to player
func _on_dash_attack_state_entered() -> void:
	anim_sprite.play("attack")
	play_sound("attack")
	dash_attack_timer = 0
	current_dashes += 1
	dash_attack_vector = global_position.direction_to(target_creature.global_position)
	dash_attack_area.monitoring = true

# Dash to player. Dash speed determined by dash_attack_duration.
func _on_dash_attack_state_physics_processing(delta: float) -> void:
	dash_attack_timer += delta
	if dash_attack_timer >= dash_attack_duration:
		statechart.send_event("on_dash_attack_finish")
	else:
		velocity = dash_attack_vector * roll_speed(dash_attack_timer, dash_attack_duration, dash_attack_range, passive_speed)
		move_and_slide()

# Exit Attack state after dashing 3 times.
func _on_dash_attack_state_exited() -> void:
	dash_attack_area.monitoring = false
	# Exit entire Attack state, go back to Active state
	if current_dashes >= num_dashes:
		statechart.send_event("on_attack_finish")


# Calculate how fast enemy dash attack over time, slow down as it finished
func _on_chase_radius_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player") and not in_attack_state:
		super (area)

func _on_attack_state_entered() -> void:
	in_attack_state = true

func _on_attack_state_exited() -> void:
	anim_sprite.play("default")
	current_dashes = 0
	dash_attack_timer = 0
	in_attack_state = false

func _on_passive_state_entered() -> void:
	super ()
	play_sound("idle")

func _on_active_state_entered() -> void:
	super ()
	play_sound("hunt")

func damage(value: int):
	super (value)
	play_sound("hurt")


func _on_dash_attack_area_body_entered(body: Node2D) -> void:
	if body is Player:
		body.damage(base_damage)
