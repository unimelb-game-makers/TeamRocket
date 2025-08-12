extends Enemy
class_name BasicEnemy

# BasicEnemy is non-boss enemy with uhh basic behaviours.

# FIXME: Navigation didnt work properly, should fix it

@export var passive_speed = 85
@export var active_speed = 180

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var statechart: StateChart = $StateChart
@onready var elite_effects: Node2D = $EliteEffects
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_sfx_player: AudioStreamPlayer2D = $HitSfxPlayer2D
@onready var alert_status_label: Label = $AlertStatusLabel

const ELITE_HP_MULT = 1.5
const ELITE_DMG_MULT = 1.5
const ELITE_SPEED_MULT = 1.2
const HIT_SHRINK_AMOUNT = 0.95

var navigation_region: NavigationRegion2D
var movement_speed: float
var movement_target_position: Vector2
var target_creature: CharacterBody2D
var hidden_target_creature: CharacterBody2D # When player is hidden, hold the player node here incase player reappear
var map
var path = []
var last_known_position: Vector2 # Last known position of player

# Search Area variables
var num_searches = 0 # Total number of "Search Areas"
var time_searching: float = 0 # Amount of time searching in one direction in Search Area
var search_min_duration: float = 0.3
var search_max_duration: float = 0.8
var search_direction: Vector2

# Pause duration set in state chart
var original_position: Vector2

func _ready():
	super ()
	navigation_region = get_tree().get_first_node_in_group("navigation")
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	#navigation_agent.path_desired_distance = 8.0
	#navigation_agent.target_desired_distance = 8.0
	movement_target_position = position;

	# Make sure to not await during _ready.
	call_deferred("setup_navserver")

	movement_speed = passive_speed
	original_position = Vector2(position)

	var elite_chance = randi_range(1, 5)
	if (elite_chance == 1):
		is_elite = true

	if (is_elite):
		elite_effects.show()
		max_health = int(max_health * ELITE_HP_MULT)
		health = int(health * ELITE_HP_MULT)
		base_damage = int(base_damage * ELITE_DMG_MULT)
		active_speed *= ELITE_SPEED_MULT

	alert_status_label.visible = false

func alerted(sound_position: Vector2):
	super (sound_position)
	last_known_position = sound_position
	statechart.send_event("to_search") # Triggers To Search State

func setup_navserver():
	# Create new navigation server map
	map = NavigationServer2D.map_create()
	NavigationServer2D.map_set_active(map, true)

	# Create a new navigation region and add it to the map
	var region = NavigationServer2D.region_create()
	NavigationServer2D.region_set_transform(region, Transform2D())
	NavigationServer2D.region_set_map(region, map)

	# Set navigation mesh for the Navigation Region from main scene
	var navigation_poly = NavigationMesh.new()
	navigation_poly = navigation_region.navigation_polygon
	NavigationServer2D.map_set_cell_size(map, 1)
	NavigationServer2D.region_set_navigation_polygon(region, navigation_poly)

func update_navigation_path(start_pos, end_pos):
	path = NavigationServer2D.map_get_path(map, start_pos, end_pos, true)
	path.remove_at(0)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target


func damage(value: int, _damage_source_position: Vector2 = Vector2.ZERO):
	super (value)
	# Tint sprite red
	var tween = create_tween()
	tween.tween_property(anim_sprite, "self_modulate", Color.RED, 0.1)
	tween.tween_property(anim_sprite, "self_modulate", Color(1, 1, 1), 0.1)

	# Shrink sprite a bit
	var before_hit_scale = anim_sprite.scale
	var tween2 = create_tween()
	tween2.tween_property(anim_sprite, "scale", before_hit_scale * HIT_SHRINK_AMOUNT, 0.1)
	tween2.tween_property(anim_sprite, "scale", before_hit_scale, 0.1)
	hit_sfx_player.play()

	target_creature = Globals.player
	statechart.send_event("to_chase")

func die():
	if (is_elite):
		drop_item()
	super ()

# FIXME: Enemy's speed when using this function is not consistent
func move_along_path(delta):
	if path.is_empty():
		velocity = Vector2.ZERO
		return

	var direction = (path[0] - global_position).normalized()
	velocity = direction * movement_speed

	var move_amount = velocity * delta
	if move_amount.length() >= global_position.distance_to(path[0]):
		global_position = path[0]
		path.remove_at(0)
	else:
		move_and_slide()

func _on_recalculate_path_timeout() -> void:
	if (target_creature):
		update_navigation_path(position, target_creature.global_position)

## Detection and Chase Radius interactions

func _on_detection_radius_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		var new_target = area.get_parent()

		if new_target is Player:
			var player: Player = new_target
			if player.is_hidden_count > 0 and target_creature == null:
				hidden_target_creature = player
				return

		target_creature = new_target
		statechart.send_event("player_detected") # Triggers To Chase State

func _on_chase_radius_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		var new_target = area.get_parent()

		if new_target is Player:
			var player: Player = new_target
			if player.is_hidden_count > 0 and target_creature == null:
				hidden_target_creature = player
				return

		# When this enemy is searching for the player,
		# if they are still in the chase radius, then continue chasing.
		target_creature = new_target
		statechart.send_event("to_chase_from_search") # Triggers To Chase

func _on_chase_radius_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player"):
		# When chasing, take note of last known position.
		# This enemy will travel to this position to search,
		# only after path has no more points.
		if target_creature != null:
			last_known_position = target_creature.position

		target_creature = null
		hidden_target_creature = null
		statechart.send_event("to_search_from_chase") # Triggers To Search


### Passive States (Idle or Wandering)

func _on_idle_state_entered() -> void:
	statechart.send_event("wander")

func _on_passive_state_entered() -> void:
	alert_status_label.visible = false
	movement_speed = passive_speed

func _on_passive_state_exited() -> void:
	alert_status_label.text = "!!!"
	alert_status_label.visible = true


### Active States (Chasing, Searching or Running away)

func _on_active_state_entered() -> void:
	movement_speed = active_speed

## Chase

func _on_chase_state_entered() -> void:
	alert_status_label.text = "!!!"

func _on_chase_state_physics_processing(delta: float) -> void:
	# Travels along points in path.
	move_along_path(delta)
	move_and_slide()

## Search
func _on_search_state_entered() -> void:
	alert_status_label.text = "?"


## Search Last Seen Position
func _on_search_last_seen_position_state_physics_processing(delta: float) -> void:
	# Finish walking along path first
	if path.size():
		move_along_path(delta)
		move_and_slide()

	# When no more points in path, walk to last known position
	else:
		position = position.lerp(last_known_position, movement_speed * delta / position.distance_to(last_known_position))
		move_and_slide()

		if position.distance_to(last_known_position) < 10: # less tolerance = jittering
			statechart.send_event("reach_last_seen_position")


## Search Area

func _on_search_area_state_entered() -> void:
	# Move in a random direction for a random duration, 3 times.
	# TODO: Pick a random point in an area, and use Navigation Agent to navigate to that instead
	search_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	time_searching = randf_range(search_min_duration, search_max_duration)

func _on_search_area_state_physics_processing(delta: float) -> void:
	time_searching -= delta

	velocity = search_direction * passive_speed
	move_and_slide()

	if time_searching < 0:
		velocity = Vector2.ZERO
		statechart.send_event("search_area_pause") # Triggers To Pause

func _on_search_area_state_exited() -> void:
	num_searches += 1


## Pause

func _on_pause_state_entered() -> void:
	velocity = Vector2.ZERO

func _on_pause_state_exited() -> void:
	if num_searches == 3:
		statechart.send_event("to_return") # Triggers To Return
		num_searches = 0


## Return to original position

func _on_return_state_entered() -> void:
	navigation_agent.target_position = original_position

func _on_return_state_physics_processing(_delta: float) -> void:
	var direction = navigation_agent.get_next_path_position() - global_position
	velocity = direction.normalized() * passive_speed
	move_and_slide()

	if position.distance_to(original_position) < 10:
			statechart.send_event("reach_initial_position")

func _on_return_state_exited() -> void:
	#navigation_agent.target_position = null
	velocity = Vector2.ZERO # If removed conflicts with chase speed when player re-enters chase radius, still taking a look
	pass


func roll_speed(elapsed_time: float, atk_duration: float, atk_range: float, atk_speed: float) -> float:
	var t: float = elapsed_time / atk_duration
	return atk_range - (atk_range - atk_speed) * t * t
