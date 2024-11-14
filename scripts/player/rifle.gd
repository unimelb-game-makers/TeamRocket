extends Node2D

@export var bullet_scene: Resource
@onready var raycast = $RayCast2D

# Inaccuracy value in degrees. Raycast will fire on a random degrees within -inaccuracy to +inaccuracy
@export var MAX_INACCURACY: float = 45.0
@export var INACCURACY_CHANGE_RATE: float = 1.0
var inaccuracy: float = 0.0: 
	set(inaccuracy_in):
		inaccuracy = clamp(inaccuracy_in, 0, MAX_INACCURACY)
		
func _process(_delta):
	look_at(get_global_mouse_position())
	raycast.rotation_degrees = 0
	raycast.rotation_degrees += randf_range(-inaccuracy, inaccuracy)
	if Input.is_action_just_pressed("fire"):
		print("Fired!")
		print("Inaccuracy: " + str(inaccuracy))
		var target_hit = raycast.get_collider()
		if (target_hit):
			print(target_hit)
