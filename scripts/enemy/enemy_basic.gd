extends CharacterBody2D

const PASSIVE_SPEED : int = 85
const ACTIVE_SPEED : int = 180

var movement_speed : float # Current default state is Passive

var movement_target_position: Vector2
var target_creature: CharacterBody2D

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@export var navigation_region: NavigationRegion2D

@onready var statechart = $StateChart

var map
var path = []

var last_known_position: Vector2

# Search Area variables
var num_searches = 0

var time_searching: float = 0
var search_min_duration: float = 0.3
var search_max_duration: float = 0.8
var search_direction: Vector2

var time_pausing: float = 0
var pause_duration = .5

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	#navigation_agent.path_desired_distance = 8.0
	#navigation_agent.target_desired_distance = 8.0
	movement_target_position = position;

	# Make sure to not await during _ready.
	call_deferred("setup_navserver")
	
	movement_speed = PASSIVE_SPEED

#func actor_setup():
	## Wait for the first physics frame so the NavigationServer can sync.
	#await get_tree().physics_frame
#
	## Now that the navigation map is no longer empty, set the movement target.
	#set_movement_target(movement_target_position)

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
	
#func _process(delta):
	#if (target_creature):
		#update_navigation_path(position, target_creature.global_position)

func _physics_process(delta):
	### Moved to chase_state_physics_processing
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







func _on_detection_radius_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		target_creature = area.get_parent();
		
		statechart.send_event("on_detection_radius_entered")
		# Idea for an "Alerted" state for a split second?


func _on_chase_radius_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		target_creature = area.get_parent();
		
		# When this enemy is searching for the player,
		# if they are still in the chase radius, then continue chasing.
		statechart.send_event("found_target")

func _on_chase_radius_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player"):
		
		# When chasing, take note of last known position. 
		# This enemy will travel to this position to search,
		# only after path has no more points.
		last_known_position = target_creature.position
		
		target_creature = null
		statechart.send_event("target_exit_chase_radius")





### Passive States (Idle or Wandering)

func _on_passive_state_entered() -> void:
	movement_speed = PASSIVE_SPEED

### Active States (Chasing or Searching)

func _on_active_state_entered() -> void:
	movement_speed = ACTIVE_SPEED	

func _on_chase_state_physics_processing(delta: float) -> void:
	var walk_distance = movement_speed * delta
	move_along_path(walk_distance)
	move_and_slide()
	
### Searching

## Search Last Seen Position
func _on_search_last_seen_position_state_physics_processing(delta: float) -> void:
	
	# Finish walking along path first
	if path.size():
		var walk_distance = movement_speed * delta
		move_along_path(walk_distance)
		move_and_slide()
	else:
		var direction = position.direction_to(last_known_position)
		
		position = position.lerp(last_known_position, movement_speed * delta / position.distance_to(last_known_position))
		
		move_and_slide()
		
		if position.distance_to(last_known_position) < 10: # less tolerance results in jittering
			statechart.send_event("reach_last_seen_position")

func _on_search_area_state_entered() -> void:
	# Move in a random direction for a random duration, 3 times.
	# TODO: Pick a random point in an area, and use Navigation Agent to navigate to that instead
	search_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	time_searching = randf_range(search_min_duration, search_max_duration)


func _on_search_area_state_physics_processing(delta: float) -> void:
	if num_searches == 3:
		statechart.send_event("target_not_found")
		return
	
	time_searching -= delta
	
	#position = position.lerp(last_known_position, movement_speed * delta / position.distance_to(search_position))
	velocity = search_direction * PASSIVE_SPEED
	move_and_slide()
	
	if time_searching < 0:
		velocity = Vector2.ZERO
		statechart.send_event("search_area_pause")


func _on_return_state_physics_processing(delta: float) -> void:
	pass


func _on_search_area_state_exited() -> void:
	pass # Replace with function body.
