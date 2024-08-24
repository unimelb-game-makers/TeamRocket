extends CharacterBody2D

@export var movement_speed: float = 100.0
var movement_target_position: Vector2
var target_creature: CharacterBody2D

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	#navigation_agent.path_desired_distance = 8.0
	#navigation_agent.target_desired_distance = 8.0
	movement_target_position = position;

	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target
	
func _process(delta):
	if (target_creature):
		set_movement_target(target_creature.global_position);

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	move_and_slide()


func _on_detection_radius_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		target_creature = area.get_parent();


#func _on_detection_radius_area_exited(area: Area2D) -> void:
	#if area.is_in_group("Player"):
		#target_creature = null
