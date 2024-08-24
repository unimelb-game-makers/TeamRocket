extends CharacterBody2D

@export var movement_speed: float = 100.0
var movement_target_position: Vector2
var target_creature: CharacterBody2D

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@export var navigation_region: NavigationRegion2D

var map
var path = []

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	#navigation_agent.path_desired_distance = 8.0
	#navigation_agent.target_desired_distance = 8.0
	movement_target_position = position;

	# Make sure to not await during _ready.
	call_deferred("setup_navserver")

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
	#if navigation_agent.is_navigation_finished():
		#return
#
	#var current_agent_position: Vector2 = global_position
	#var next_path_position: Vector2 = navigation_agent.get_next_path_position()
#
	#velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	var walk_distance = movement_speed * delta
	move_along_path(walk_distance)
	move_and_slide()

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
	set_process(false)

func _on_detection_radius_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		target_creature = area.get_parent();

func _on_chase_radius_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player"):
		target_creature = null

func _on_recalculate_path_timeout() -> void:
	if (target_creature):
		update_navigation_path(position, target_creature.global_position)
