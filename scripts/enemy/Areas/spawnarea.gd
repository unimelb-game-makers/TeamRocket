extends Area2D

# Spawns enemy within radius

# Make sure this is not 0
@export var allowed_enemies: Array[PackedScene] = []

@onready var radius = $CollisionShape2D.shape.radius

func _ready() -> void:
	assert(len(allowed_enemies) > 0) 

func spawn_single():
	
	var e = allowed_enemies.pick_random().instantiate()
	e.global_position = global_position + radius * get_random_point()
	
	# Add child to root node
	get_tree().root.add_child(e)


func spawn_batch(amount: int):
	
	pass

func get_random_point():
	var x = sin(randf_range(-radius, radius))
	var y = cos(randf_range(-radius, radius))
	return Vector2(x , y)

# Testing purposes
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("roll"):
		spawn_single()
