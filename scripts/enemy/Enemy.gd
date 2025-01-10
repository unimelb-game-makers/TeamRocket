class_name Enemy
extends CharacterBody2D

@export var max_health: int
@export var base_move_speed: float
@export var base_damage: int
@export var base_attack_cooldown: float

@onready var health = max_health
@onready var move_speed = base_move_speed

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var detection_radius: Area2D = $DetectionRadius
@onready var chase_radius: Area2D = $ChaseRadius
@onready var recalculate_path: Timer = $RecalculatePath
var navigation_region: NavigationRegion2D
var map
var path = []
var target_creature: CharacterBody2D
var state

func _ready() -> void:
	navigation_region = get_tree().get_first_node_in_group("navigation")
	if navigation_region:
		call_deferred("setup_navserver")

func setup_navserver():
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

func _physics_process(delta):
	var walk_distance = move_speed * delta
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
	target_creature = area.get_parent();

func _on_chase_radius_area_exited(area: Area2D) -> void:
	target_creature = null

func _on_recalculate_path_timeout() -> void:
	if (target_creature):
		update_navigation_path(position, target_creature.global_position)
