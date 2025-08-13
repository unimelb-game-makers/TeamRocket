@tool
extends Area2D
class_name SpawnArea

# Spawns enemy within radius
# The CollisionShape2D is local to scene, so if there are multiple of this node,
# the radius or even shape can be changed dynamically in the editor. You just need
# to right click this scene and select "Editable Children".

# Make sure this is not 0
@export var allowed_enemies: Array[PackedScene] = []
@export var radius: float:
	set(x):
		radius = x
		if collision_shape:
			collision_shape.shape.radius = x

# Expose CollisionShape radius to scene root in editor
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	assert(allowed_enemies.size() > 0)
	collision_shape.shape.radius = radius

func spawn_single():
	var enemy_inst = allowed_enemies.pick_random().instantiate()
	# Add child to root node
	Globals.enemy_handler.add_child(enemy_inst)
	Globals.enemy_handler.add_enemy_to_list(enemy_inst)
	enemy_inst.global_position = global_position + collision_shape.shape.radius * get_random_point()


func spawn_batch(amount: int):
	for i in range(amount):
		spawn_single()

func get_random_point():
	var r = collision_shape.shape.radius
	var x = sin(randf_range(-r, r))
	var y = cos(randf_range(-r, r))
	return Vector2(x, y)
