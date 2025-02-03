extends Enemy

const SPEEDS = [0, 45, 200]

var movement_speed : float # Current default state is Passive

var movement_target_position: Vector2
var target_creature: CharacterBody2D
var direction = Vector2(0,0)

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_change_timer: Timer = $StateChangeTimer
@onready var detection_area: Area2D = $DetectionArea
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@export var navigation_region: NavigationRegion2D

var map
var path = []

enum ChickenState {NEUTRAL, WALKING, RUNNING}
var state = ChickenState.NEUTRAL

func _physics_process(delta: float) -> void:
	if (state == ChickenState.NEUTRAL):
		pass
	if (state == ChickenState.WALKING or ChickenState.RUNNING):
		velocity = direction * movement_speed
		if (velocity.x > 0.0):
			animated_sprite_2d.flip_h = true
		else:
			animated_sprite_2d.flip_h = false
	move_and_slide()

func _on_state_change_timer_timeout() -> void:
	var state_changing = randi_range(0, 1)
	if state == ChickenState.RUNNING and detection_area.has_overlapping_bodies():
		change_state(ChickenState.RUNNING)
	else:
		change_state(ChickenState[ChickenState.keys()[state_changing]])
		
func enter_running_state() -> void:
	change_state(ChickenState.RUNNING)
	state_change_timer.wait_time = 6.0
	state_change_timer.start(0)
	
func change_state(new_state: ChickenState) -> void:
	state = new_state
	movement_speed = SPEEDS[new_state]
	state_change_timer.wait_time = randf_range(1.0, 4.0)
	direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	match state:
		ChickenState.NEUTRAL:
			animated_sprite_2d.play("neutral")
		ChickenState.WALKING:
			animated_sprite_2d.play("walk")
		ChickenState.RUNNING:
			animated_sprite_2d.play("walk", 3.0)

func damage() -> void:
	super()
	enter_running_state()
