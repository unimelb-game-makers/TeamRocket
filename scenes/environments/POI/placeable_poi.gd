extends Node2D
class_name PlaceablePOI

enum EnterDirectionEnum {
	NONE,
	TOP,
	DOWN,
	LEFT,
	RIGHT
}

enum UniquePoiEnum {
	NONE,
	RESTAURANT,
	ALCOVE,
	KINGDOM,
	CONSTELLATIONS
}

@export var potential_enter_direction: EnterDirectionEnum
@export var poi_loot_table: Array[Item] = []

@onready var enemy_holder: Node2D = $EnemyHolder
@onready var spawn_holder: Node2D = $SpawnHolder
@onready var interactable_holder: Node2D = $InteractableHolder

var map_room: ProceduralRoom # Set in procedural_room.gd

func generate_loot_for_container():
	var combined_loot_table = Globals.interactable_handler.global_loot_table
	combined_loot_table.append_array(poi_loot_table)
	if map_room:
		combined_loot_table.append_array(map_room.map_loot_table)

	for elem in interactable_holder.get_children():
		if elem is Storage:
			var crate = elem as Storage
			if crate.randomized_loot:
				crate.generate_loot(combined_loot_table)

func get_enemy_spawns():
	return spawn_holder.get_children()

func get_enemies():
	return enemy_holder.get_children()

func get_interactables():
	return interactable_holder.get_children()
