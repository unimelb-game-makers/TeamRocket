extends StaticBody2D

@export var spoon: RigidBody2D

func _physics_process(delta):
	pass
	
	global_position = lerp(global_position, get_global_mouse_position(), 60*delta) #make StaticBody2d follow mouse 
	
	if Input.is_action_pressed("fire"):
		if spoon.is_dragging == true:
			$PinJoint2D.node_b = spoon.get_path() # attached the PinJoint2d to the top object 
		elif Input.is_action_just_released("fire"): 
			$PinJoint2D.node_b = ""
