extends Node2D

var bodies: Array[Array] = []
var total_bodies = 0

@export var texture: Texture2D
@onready var force: float = 500
@onready var circle := CircleShape2D.new()
var spawnRadius: float = 10
signal created_blob

var textureSize: float = 48

func _ready() -> void:
	circle.radius = 8
	circle.custom_solver_bias = .1
	
	# Resize shader to apply to the whole screen
	$ColorRect.global_position = Vector2(0,0)
	$ColorRect.size = get_viewport_rect().size


func create_body(pos: Vector2) -> void:
	var physics := PhysicsServer2D
	var body = physics.body_create()
	
	physics.body_set_space(body, get_world_2d().space)
	physics.body_add_shape(body, circle)
	physics.body_set_param(body, physics.BODY_PARAM_FRICTION, .01)
	physics.body_set_param(body, physics.BODY_PARAM_MASS, 0.1)
	physics.body_set_mode(body, physics.BODY_MODE_RIGID_LINEAR)
	
	var tf := Transform2D(0, pos)
	physics.body_set_state(body, physics.BODY_STATE_TRANSFORM, tf)
	
	var rendering := RenderingServer
	var image := rendering.canvas_item_create()
	rendering.canvas_item_set_parent(image, get_canvas_item())
	rendering.canvas_item_add_texture_rect(
		image, 
		Rect2(textureSize/-2, textureSize/-2, textureSize, textureSize), 
		texture
	)
	rendering.canvas_item_set_transform(image, tf)
	
	bodies.append([body, image])
	total_bodies += 1
	created_blob.emit()

func _physics_process(delta: float) -> void:
	var i: int = 0
	for pair in bodies:
		var body: RID = pair[0]
		var image: RID = pair[1]
		var physics := PhysicsServer2D
		var render := RenderingServer
		var trans: Transform2D = physics.body_get_state(body, physics.BODY_STATE_TRANSFORM)
		
		trans.origin -= global_position
		# Remove body if out of screen
		if trans.origin.y > get_viewport_rect().size.y - global_position.y:
			bodies.remove_at(i)
			physics.free_rid(body)
			render.free_rid(image)
		else:
			render.canvas_item_set_transform(image, trans)
			physics.body_set_constant_force(body, Vector2.ZERO)
		i += 1

func _exit_tree() -> void:
	for pair in bodies:
		var body: RID = pair[0]
		var image: RID = pair[1]
		PhysicsServer2D.free_rid(body)
		RenderingServer.free_rid(image)

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		create_body(global_position + Vector2(randf()-.5, randf()-.5).normalized()*spawnRadius*randf())
