extends Area2D

# Spawns enemy within radius
# The CollisionShape2D is local to scene, so if there are multiple of this node,
# the radius or even shape can be changed dynamically in the editor. You just need 
# to right click this scene and select "Editable Children".

# Make sure this is not 0
@export var allowed_enemies: Array[PackedScene] = []

# Expose CollisionShape radius to scene root in editor
@onready var collisionshape: CollisionShape2D = $CollisionShape2D
@export var radius: float:
	set(x):
		radius = x
		if collisionshape:
			collisionshape.radius = x


func _ready() -> void:
	#assert(len(allowed_enemies) > 0)
	assert(allowed_enemies.size() > 0)
	#print(allowed_enemies.size())
	#print(radius)
	
	collisionshape.set("radius", radius)

# Make sure 
func spawn_single():
	var e = allowed_enemies.pick_random().instantiate()
	e.global_position = global_position + collisionshape.radius * get_random_point()
	
	# Add child to root node
	get_tree().root.add_child(e)


func spawn_batch(amount: int):
	for i in range(amount):
		spawn_single()

func get_random_point():
	var r = collisionshape.radius
	var x = sin(randf_range(-r, r))
	var y = cos(randf_range(-r, r))
	return Vector2(x , y)
