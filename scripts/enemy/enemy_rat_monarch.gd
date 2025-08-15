extends BasicEnemy

@export var split_hp_threshold = 0.66
@export var max_split_time = 2
@export var n_rat_after_split = 2
@export var attack_cooldown = 2

@onready var dash_atk_area: Area2D = $DashAttackArea
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@onready var idle_large_effect: AudioStreamPlayer2D = $SoundEffects/IdleLargeEffect
@onready var idle_medium_effect: AudioStreamPlayer2D = $SoundEffects/IdleMediumEffect
@onready var idle_small_effect: AudioStreamPlayer2D = $SoundEffects/IdleSmallEffect
@onready var attack_effect: AudioStreamPlayer2D = $SoundEffects/AttackEffect
@onready var hurt_effect: AudioStreamPlayer2D = $SoundEffects/HurtEffect
@onready var death_effect: AudioStreamPlayer2D = $SoundEffects/DeathEffect

var anim_sprite_original_pos: Vector2
var anim_sprite_original_scale: Vector2
var is_attacking = false
var range_before_attack = 500

var attack_cooldown_timer = 0

var pounce_attack_vector: Vector2
var pounce_attack_range: float = 1000
var pounce_attack_timer: float = 0
var pounce_attack_duration: float = 1
var max_pounce_distance = 1000

var zigzag_amplitude = 50.0 # Adjust for wider or narrower zigzag
var zigzag_frequency = 3.0 # Adjust for faster or slower zigzag
var zigzag_time := 0.0

var splitted_time = 0
var rat_monarch_packed_scene: PackedScene = preload("res://scenes/enemy/EnemyRatMonarch.tscn") as PackedScene

func _ready() -> void:
	super ()
	anim_sprite_original_pos = anim_sprite.position

func _process(delta: float) -> void:
	attack_cooldown_timer += delta

	if not anim_sprite.flip_h and velocity.x > 0.1:
		anim_sprite.flip_h = true
	elif anim_sprite.flip_h and velocity.x < -0.1:
		anim_sprite.flip_h = false

func splitted_rat_init(_max_health: int, _base_damage: int, _splitted_time: int, spawn_pos: Vector2, _scale: Vector2):
	await ready
	max_health = _max_health
	base_damage = _base_damage
	health = max_health
	splitted_time = _splitted_time
	scale = _scale
	# Randomize spawn pos a bit
	var rand_x = randf_range(-50, 50)
	var rand_y = randf_range(-50, 50)
	global_position = spawn_pos + Vector2(rand_x, rand_y)
	simulate_pounce_attack_jump()


func simulate_pounce_attack_jump():
	var jump_height = 50
	var jump_duration = 0.5
	var tween = create_tween()
	tween.tween_property(anim_sprite, "position:y", anim_sprite_original_pos.y - jump_height, jump_duration / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(anim_sprite, "position:y", anim_sprite_original_pos.y, jump_duration / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

# Override basic_enemy to make rat monarch travel in a zigzag pattern
func move_along_path(delta):
	if path.is_empty():
		velocity = Vector2.ZERO
		return

	var target_pos = path[0]
	var direction = (target_pos - global_position).normalized()
	zigzag_time += delta

	# Create a perpendicular direction to the path
	var perpendicular = Vector2(-direction.y, direction.x)
	# Add oscillation to the direction for zigzag
	var zigzag_offset = perpendicular * sin(zigzag_time * zigzag_frequency) * zigzag_amplitude
	var zigzag_direction = (direction * movement_speed + zigzag_offset).normalized()

	velocity = zigzag_direction * movement_speed
	var move_amount = velocity * delta

	# Check if we're close enough to the next point
	if move_amount.length() >= global_position.distance_to(target_pos):
		global_position = target_pos
		path.remove_at(0)
	else:
		move_and_slide()


func damage(value: int, damage_source_position: Vector2 = Vector2.ZERO) -> void:
	super (value, damage_source_position)
	hurt_effect.play()
	if health <= max_health * 0.66 and splitted_time < max_split_time:
		split()

func split():
	for i in range(n_rat_after_split):
		var rat_inst = rat_monarch_packed_scene.instantiate()
		Globals.enemy_handler.call_deferred("add_child", rat_inst)
		Globals.enemy_handler.call_deferred("add_enemy_to_list", rat_inst)
		# Set up the stat for the splitted rat
		rat_inst.splitted_rat_init(health, int(base_damage / 2.0), splitted_time + 1, global_position, scale / 2)
		if target_creature != null:
			rat_inst.target_creature = target_creature
			statechart.send_event("to_chase")
		# Delay before spawn the next one to add a bit variety
		await get_tree().create_timer(0.1).timeout

	# Destroy this rat
	die()

func die():
	death_effect.play()
	super ()

func _on_chase_state_physics_processing(delta: float) -> void:
	var distance = global_position.distance_to(target_creature.global_position)
	if distance < range_before_attack:
		if attack_cooldown_timer > attack_cooldown:
			statechart.send_event("to_attack")
		return
	super (delta)

func _on_chase_radius_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player") and not is_attacking:
		super (area)

func _on_attack_state_entered() -> void:
	attack_effect.play()
	is_attacking = true


func _on_attack_state_exited() -> void:
	is_attacking = false

func _on_wind_up_state_entered() -> void:
	statechart.send_event("to_pounce_attack")

func _on_pounce_attack_state_entered() -> void:
	simulate_pounce_attack_jump()
	dash_atk_area.monitoring = true
	# anim_sprite.play("attack")
	# attack_effect.play()
	pounce_attack_timer = 0
	pounce_attack_vector = global_position.direction_to(target_creature.global_position)
	pounce_attack_range = clamp(global_position.distance_to(target_creature.global_position) * 2, 0, max_pounce_distance)

func _on_pounce_attack_state_physics_processing(delta: float) -> void:
	pounce_attack_timer += delta
	if pounce_attack_timer >= pounce_attack_duration:
		velocity = Vector2.ZERO
		statechart.send_event("to_chase")
		attack_cooldown_timer = 0
		return
	else:
		velocity = pounce_attack_vector * roll_speed(pounce_attack_timer, pounce_attack_duration, pounce_attack_range, movement_speed / 2.0)
		move_and_slide()

func _on_pounce_attack_state_exited() -> void:
	dash_atk_area.monitoring = false

func _on_attack_state_physics_processing(_delta: float) -> void:
	if target_creature == null:
		statechart.send_event("to_search")
		return
	var distance = global_position.distance_to(target_creature.global_position)
	if distance > range_before_attack * 1.2:
		statechart.send_event("player_out_of_atk_range")
		return

func _on_dash_attack_area_body_entered(body: Node2D) -> void:
	if body is Player:
		body.damage(base_damage)
	# TODO: Apply poison to player here

func _on_passive_state_entered() -> void:
	super ()
	if splitted_time == 0:
		idle_large_effect.play()
	elif splitted_time == 1:
		idle_medium_effect.play()
	else:
		idle_small_effect.play()
