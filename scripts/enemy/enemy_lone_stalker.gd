extends BasicEnemy

@export var runaway_duration: float = 4
@export var transparency_when_stalk: float = 0.1

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_atk_area: Area2D = $DashAttackArea
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var stop_run_timer: Timer = $StopRunTimer

const AIM_THRESHOLD_IN_DEGREE = 90
const RUNAWAY_SPEED_MULT = 5.0
const STALK_SPEED_MULT = 0.5
const FAST_ANIM_SPEED_SCALE = 3.0

var anim_sprite_original_pos: Vector2
var is_attacking = false
var range_before_attack = 500

var runaway_direction: Vector2

var pounce_attack_vector: Vector2
var pounce_attack_range: float = 1000
var pounce_attack_timer: float = 0
var pounce_attack_duration: float = 1
var max_pounce_distance = 1000

# If this is true, lone stalker won't run when shot anymore
var committed_to_attack = false

func _ready() -> void:
	super ()
	anim_sprite_original_pos = anim_sprite.position

func _process(_delta: float) -> void:
	if not anim_sprite.flip_h and velocity.x > 0.1:
		anim_sprite.flip_h = true
	elif anim_sprite.flip_h and velocity.x < -0.1:
		anim_sprite.flip_h = false


func _on_chase_state_entered() -> void:
	var tween = create_tween()
	tween.tween_property(anim_sprite, "self_modulate:a", transparency_when_stalk, 1)
	# anim_sprite.self_modulate = Color(1, 1, 1, transparency_when_stalk)


func _on_chase_state_physics_processing(delta: float) -> void:
	if target_creature != null and not is_attacking:
		if committed_to_attack:
			movement_speed = active_speed
			anim_sprite.speed_scale = FAST_ANIM_SPEED_SCALE
		else:
			if check_player_moving():
				movement_speed = 0
				anim_sprite.speed_scale = 0
			else:
				movement_speed = active_speed * STALK_SPEED_MULT
				anim_sprite.speed_scale = 1
	if target_creature == null:
		statechart.send_event("to_search")
		return
	var distance = global_position.distance_to(target_creature.global_position)
	if distance < range_before_attack:
		statechart.send_event("to_attack")
		return
	super (delta)

func _on_chase_state_exited() -> void:
	var tween = create_tween()
	tween.tween_property(anim_sprite, "self_modulate:a", 1, 1)
	# anim_sprite.self_modulate = Color(1, 1, 1, 1)

func check_player_is_looking_at_enemy() -> bool:
	if target_creature == null or not target_creature is Player:
		return false
	var player = target_creature as Player
	var player_ray_origin = player.rifle.raycast.global_position
	var dir_to_enemy = (global_position - player_ray_origin).normalized()
	var angle_diff = fmod(abs(player.rifle.raycast.global_rotation - dir_to_enemy.angle()), (PI * 2))
	return angle_diff <= deg_to_rad(AIM_THRESHOLD_IN_DEGREE / 2.0)

func check_player_moving() -> bool:
	if target_creature == null or not target_creature is Player:
		return false
	var player = target_creature as Player
	return player.velocity.length() > 0.1


func damage(value: int) -> void:
	super (value)
	# hurt_effect.play()
	var tween = create_tween()
	tween.tween_property(anim_sprite, "self_modulate:a", 1, 1)
	if not committed_to_attack:
		statechart.send_event("to_runaway")

func _on_chase_radius_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player") and not is_attacking:
		super (area)

func _on_attack_state_entered() -> void:
	is_attacking = true
	committed_to_attack = true

func _on_attack_state_exited() -> void:
	is_attacking = false

func _on_wind_up_state_entered() -> void:
	statechart.send_event("to_pounce_attack")

func _on_pounce_attack_state_entered() -> void:
	dash_atk_area.monitoring = true
	# anim_sprite.play("attack")
	# attack_effect.play()
	pounce_attack_timer = 0
	pounce_attack_vector = global_position.direction_to(target_creature.global_position)
	pounce_attack_range = clamp(global_position.distance_to(target_creature.global_position) * 2, 0, max_pounce_distance)

func _on_pounce_attack_state_physics_processing(delta: float) -> void:
	pounce_attack_timer += delta
	if pounce_attack_timer >= pounce_attack_duration:
		statechart.send_event("to_runaway")
		return
	else:
		velocity = pounce_attack_vector * roll_speed(pounce_attack_timer, pounce_attack_duration, pounce_attack_range, movement_speed)
		move_and_slide()

func _on_pounce_attack_state_exited() -> void:
	dash_atk_area.monitoring = false

func _on_dash_attack_area_body_entered(body: Node2D) -> void:
	if body is Player:
		body.damage(base_damage)

func _on_runaway_state_entered() -> void:
	movement_speed = active_speed
	anim_sprite.speed_scale = FAST_ANIM_SPEED_SCALE
	stop_run_timer.start(runaway_duration)
	if target_creature != null:
		runaway_direction = target_creature.global_position.direction_to(global_position)
	else:
		var rand_x = randf_range(-1, 1)
		var rand_y = randf_range(-1, 1)
		runaway_direction = Vector2(rand_x, rand_y)

func _on_runaway_state_physics_processing(_delta: float) -> void:
	velocity = runaway_direction * movement_speed * RUNAWAY_SPEED_MULT
	move_and_slide()


func _on_runaway_state_exited() -> void:
	anim_sprite.speed_scale = 1

func _on_stop_run_timer_timeout() -> void:
	statechart.send_event("to_chase")
