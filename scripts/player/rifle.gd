extends Node2D

@export var bullet_scene: Resource
@onready var raycast = $RayCast2D

func _process(_delta):
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("fire"):
		var target_hit = raycast.get_collider()
		if (target_hit):
			print(target_hit)
