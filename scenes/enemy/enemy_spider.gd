extends BasicEnemy

## From 0 to 1
@export var dodge_chance_when_defend = 0.5
@export var range_before_attack = 500

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_atk_area: Area2D = $DashAttackArea

const DEFENDING_MOVESPEED_COEFFICIENT = 0.25
const AIM_THRESHOLD_IN_DEGREE = 90

var anim_sprite_original_pos: Vector2
var is_attacking = false
var is_winding_up_attack = false

var triangle_atk_calculated = false
var tri_atk_pos1: Vector2
var tri_atk_pos2: Vector2
var tri_atk_pos3: Vector2
# combo 1 = pounce to slow player
# combo 2 = triangle attack
# combo 3 = circling and binding player
var combo_counter = 0

var pounce_attack_vector: Vector2
var pounce_attack_range: float = 1000
var pounce_attack_timer: float = 0
var pounce_attack_duration: float = 1

func _ready() -> void:
	super ()
	anim_sprite_original_pos = anim_sprite.position

func _process(_delta: float) -> void:
	if not anim_sprite.flip_h and velocity.x > 0.1:
		anim_sprite.flip_h = true
	elif anim_sprite.flip_h and velocity.x < -0.1:
		anim_sprite.flip_h = false


func _on_detection_radius_area_entered(area: Area2D) -> void:
	if is_attacking:
		return
	super (area)

func _on_chase_state_physics_processing(delta: float) -> void:
	if target_creature != null and not is_attacking:
		if player_is_aiming_at_enemy():
			movement_speed = active_speed * DEFENDING_MOVESPEED_COEFFICIENT
		else:
			movement_speed = active_speed

	var distance = global_position.distance_to(target_creature.global_position)
	if distance < range_before_attack:
		statechart.send_event("to_attack")
		return
	super (delta)


func damage(value: int) -> void:
	var dodge_roll = randf_range(0, 1)
	target_creature = Globals.player
	if dodge_roll < dodge_chance_when_defend:
		play_dodge_effect()
		return
	super (value)

func play_dodge_effect():
	var tween = create_tween()
	tween.tween_property(anim_sprite, "position:y", anim_sprite_original_pos.y - 30, 0.2)
	tween.tween_property(anim_sprite, "position:y", anim_sprite_original_pos.y, 0.2)


func player_is_aiming_at_enemy() -> bool:
	if target_creature == null or not target_creature is Player:
		return false
	var player = target_creature as Player
	if not player.is_aiming:
		return false

	var player_ray_origin = player.rifle.raycast.global_position
	var dir_to_enemy = (global_position - player_ray_origin).normalized()

	var angle_diff = fmod(abs(player.rifle.raycast.global_rotation - dir_to_enemy.angle()), (PI * 2))

	return angle_diff <= deg_to_rad(AIM_THRESHOLD_IN_DEGREE / 2.0)


func _on_chase_radius_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player") and not is_attacking:
		super (area)

func _on_attack_state_entered() -> void:
	is_attacking = true


func _on_attack_state_exited() -> void:
	is_attacking = false
	combo_counter = 0


func _on_triangle_attack_state_entered() -> void:
	# Calculate 3 point around player, where 1st point is original pos,
	# 2nd and 3rd point behind player, form a triangle
	triangle_atk_calculated = false
	if target_creature == null:
		return
	tri_atk_pos1 = global_position
	var triangle_center = target_creature.global_position

	var radius: float = (triangle_center - tri_atk_pos1).length() # Distance from D to any vertex
	# Angle from player to spider pos 1
	var angle_to_pos1 = (tri_atk_pos1 - triangle_center).angle()
	# Compute other two points by rotating 120° and -120° around player
	var angle_120 = deg_to_rad(120)
	tri_atk_pos2 = triangle_center + Vector2.RIGHT.rotated(angle_to_pos1 + angle_120) * radius
	tri_atk_pos3 = triangle_center + Vector2.RIGHT.rotated(angle_to_pos1 - angle_120) * radius
	triangle_atk_calculated = true

	# Start attack here
	global_position = tri_atk_pos2
	await get_tree().create_timer(1.0).timeout
	global_position = tri_atk_pos3
	await get_tree().create_timer(1.0).timeout
	global_position = tri_atk_pos1
	await get_tree().create_timer(1.0).timeout

	statechart.send_event("to_wind_up")


func _on_wind_up_state_entered() -> void:
	is_winding_up_attack = true
	# Depend on condition here, use different attack
	statechart.send_event("to_pounce_attack")
	# statechart.send_event("to_triangle_attack")


func _on_wind_up_state_exited() -> void:
	is_winding_up_attack = false

func _on_pounce_attack_state_entered() -> void:
	play_dodge_effect()
	dash_atk_area.monitoring = true
	# anim_sprite.play("attack")
	# attack_effect.play()
	pounce_attack_timer = 0
	pounce_attack_vector = global_position.direction_to(target_creature.global_position)

func _on_pounce_attack_state_physics_processing(delta: float) -> void:
	pounce_attack_timer += delta
	if pounce_attack_timer >= pounce_attack_duration:
		statechart.send_event("to_wind_up")
		return
	else:
		velocity = pounce_attack_vector * roll_speed(pounce_attack_timer, pounce_attack_duration, pounce_attack_range, passive_speed)
		move_and_slide()

func _on_pounce_attack_state_exited() -> void:
	dash_atk_area.monitoring = false


func _on_attack_state_physics_processing(_delta: float) -> void:
	if target_creature == null:
		statechart.send_event("to_search")
		return
	var distance = global_position.distance_to(target_creature.global_position)
	if distance > range_before_attack * 1.5 and is_winding_up_attack:
		print("POPOPPO")
		statechart.send_event("to_chase")
		return
