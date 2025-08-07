extends Node2D
class_name InteractableHandler

@onready var interactable_spawn_points: Node = $InteractableSpawnPoints
@onready var interactable_holder: Node2D = $InteractableHolder

@export var crate_scene: PackedScene
@export var explosive_barrel_scene: PackedScene
@export var global_loot_table: Array[Item] = []

func _ready() -> void:
	Globals.interactable_handler = self
	for spawn_point in interactable_spawn_points.get_children():
		var spawn_loot = randf() < 0.3
		if spawn_loot:
			spawn_crate(spawn_point.global_position)


## Deprecated. It only used in City.tscn for now. Will be removed soon
func spawn_crate(spawn_pos: Vector2):
	var crate: Storage = crate_scene.instantiate()
	interactable_holder.add_child(crate)
	crate.position = spawn_pos
	crate.generate_loot(global_loot_table)
	crate.update_display()


func spawn_object(prefab_scene: PackedScene, spawn_pos: Vector2) -> Node:
	var inst = prefab_scene.instantiate()
	interactable_holder.add_child(inst)
	inst.global_position = spawn_pos
	return inst


func spawn_interactables_from_save():
	var room_data = Globals.map_generator.get_current_room_data()
	if not room_data.is_new:
		for data in room_data.room_interactable_data:
			var interactable_name = data['name']
			var interactable_global_position = data['global_position']
			match interactable_name:
				'crate':
					var inst = spawn_object(crate_scene, interactable_global_position)
					var crate_inst: Storage = inst
					crate_inst.slots_num = data['slots_num']
					crate_inst.load_loot_from_save(data['contained_items_data'])
					crate_inst.update_display()
				'explosive_barrel':
					spawn_object(explosive_barrel_scene, interactable_global_position)

func clear_room():
	for child in interactable_spawn_points.get_children():
		child.queue_free()
	for child in interactable_holder.get_children():
		child.queue_free()
