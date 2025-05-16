extends Area2D

# Spawns enemy within radius
# The CollisionShape2D is local to scene, so if there are multiple of this node,
# the radius or even shape can be changed dynamically in the editor. You just need
# to right click this scene and select "Editable Children".

# Make sure this is not 0
@export var allowed_enemies: Array[PackedScene] = []
@export var radius: float:
	set(x):
		radius = x
		if collisionshape:
			collisionshape.radius = x

# Expose CollisionShape radius to scene root in editor
@onready var collisionshape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	assert(allowed_enemies.size() > 0)
	collisionshape.set("radius", radius)

func spawn_single():
	var e = allowed_enemies.pick_random().instantiate()
	e.global_position = global_position + collisionshape.shape.radius * get_random_point()
	# Add child to root node
	Globals.enemy_handler.add_child(e)
	Globals.enemy_handler.add_enemy_to_list(e)


func spawn_batch(amount: int):
	for i in range(amount):
		spawn_single()

func get_random_point():
	var r = collisionshape.shape.radius
	var x = sin(randf_range(-r, r))
	var y = cos(randf_range(-r, r))
	return Vector2(x, y)
