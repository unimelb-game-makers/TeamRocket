extends Enemy
class_name BasicEnemy

# BasicEnemy is non-boss enemy with uhh basic behaviours.

@export var passive_speed = 85
@export var active_speed = 180

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var statechart: StateChart = $StateChart

var navigation_region: NavigationRegion2D
var movement_speed: float
var movement_target_position: Vector2
var target_creature: CharacterBody2D
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

func _physics_process(_delta):
	pass

func move_along_path(distance):
	var last_point = self.position
	while path.size():
		var distance_between_points = last_point.distance_to(path[0])
		if distance <= distance_between_points:
			self.position = last_point.lerp(path[0], distance / distance_between_points)
			return
		distance -= distance_between_points
		last_point = path[0]
		path.remove_at(0)
	self.position = last_point
	#set_process(false)

func _on_recalculate_path_timeout() -> void:
	if (target_creature):
		update_navigation_path(position, target_creature.global_position)

## Detection and Chase Radius interactions

func _on_detection_radius_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		target_creature = area.get_parent();
		statechart.send_event("on_detection_radius_entered") # Triggers To Chase State

func _on_chase_radius_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		target_creature = area.get_parent();

		# When this enemy is searching for the player,
		# if they are still in the chase radius, then continue chasing.
		statechart.send_event("found_target") # Triggers To Chase

func _on_chase_radius_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player"):
		# When chasing, take note of last known position.
		# This enemy will travel to this position to search,
		# only after path has no more points.
		last_known_position = target_creature.position

		target_creature = null
		statechart.send_event("target_exit_chase_radius") # Triggers To Search


### Passive States (Idle or Wandering)

func _on_passive_state_entered() -> void:
	movement_speed = passive_speed

### Active States (Chasing, Searching or Running away)

func _on_active_state_entered() -> void:
	movement_speed = active_speed

## Chase

func _on_chase_state_physics_processing(delta: float) -> void:
	# Travels along points in path.
	var walk_distance = movement_speed * delta
	move_along_path(walk_distance)
	move_and_slide()


## Search Last Seen Position

func _on_search_last_seen_position_state_physics_processing(delta: float) -> void:
	# Finish walking along path first
	if path.size():
		var walk_distance = movement_speed * delta
		move_along_path(walk_distance)
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
		statechart.send_event("target_not_found") # Triggers To Return
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
