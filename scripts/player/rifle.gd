extends Node2D

@export var bullet_scene: Resource
@onready var raycast = $RayCast2D

# Inaccuracy value in degrees. Raycast will fire on a random degrees within -inaccuracy to +inaccuracy
@export var MAX_INACCURACY: float = 45.0
var inaccuracy_limit: float = 0.0:
	set(limit):
		inaccuracy_limit = clamp(limit, 0, MAX_INACCURACY)
@export var INACCURACY_CHANGE_RATE_BASE: float = 0.05

var inaccuracy_change_rate: float = INACCURACY_CHANGE_RATE_BASE
var inaccuracy: float = 0.0: 
	set(inaccuracy_in):
		if (inaccuracy >= inaccuracy_limit or inaccuracy <= -inaccuracy_limit):
			inaccuracy_change_rate *= -1
			inaccuracy_in = inaccuracy + inaccuracy_change_rate
		inaccuracy = clamp(inaccuracy_in, -inaccuracy_limit, inaccuracy_limit)
		
func _process(_delta):
	look_at(get_global_mouse_position())
	inaccuracy += inaccuracy_change_rate
	raycast.rotation_degrees = inaccuracy
	if Input.is_action_just_pressed("fire"):
		print("Fired!")
		print("Inaccuracy: " + str(inaccuracy))
		var target_hit = raycast.get_collider()
		if (target_hit):
			print(target_hit)
