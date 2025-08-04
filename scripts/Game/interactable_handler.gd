extends Node2D
class_name InteractableHandler

@onready var interactable_spawn_points: Node = $InteractableSpawnPoints
@onready var interactable_holder: Node2D = $InteractableHolder

@export var crate_scene: PackedScene
@export var global_loot_table: Array[Item] = []

func _ready() -> void:
	Globals.interactable_handler = self
	for spawn_point in interactable_spawn_points.get_children():
		var spawn_loot = randf() < 0.3
		if spawn_loot:
			spawn_crate(spawn_point.global_position)
			

func spawn_crate(spawn_pos: Vector2):
	var crate: Storage = crate_scene.instantiate()
	crate.position = spawn_pos
	interactable_holder.add_child(crate)
	crate.generate_loot(global_loot_table)
	crate.update_display()


func clear_room():
	for child in interactable_spawn_points.get_children():
		child.queue_free()
	for child in interactable_holder.get_children():
		child.queue_free()
