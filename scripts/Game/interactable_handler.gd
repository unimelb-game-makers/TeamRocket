extends Node2D

@onready var interactable_spawn_points: Node = $InteractableSpawnPoints
@onready var interactable_holder: Node2D = $InteractableHolder

@export var chest_scene: PackedScene
@export var loot_table: Array[Item]

func _ready() -> void:
	for spawn_point in interactable_spawn_points.get_children():
		var spawn_loot = randf() < 0.3
		if spawn_loot:
			spawn_interactable(spawn_point.global_position)

func spawn_interactable(position: Vector2):
	var interactable = chest_scene.instantiate()
	interactable.position = position
	interactable_holder.add_child(interactable)
	interactable.items = generate_loot(interactable.slots_num)
	interactable.update_display()
	
func generate_loot(slots) -> Array[Item]:
	var loot_array: Array[Item] = []
	for i in range(slots):
		var loot = randi_range(0, len(loot_table)-1)
		loot_array.append(loot_table[loot])
		
	return loot_array
