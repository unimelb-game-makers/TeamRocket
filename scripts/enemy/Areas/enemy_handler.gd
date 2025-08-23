extends Node2D
class_name EnemyHandler

@export var min_spawns_per_area: int = 1
@export var max_spawns_per_area: int = 1

@onready var spawn_areas: Node = $SpawnAreas

var enemy_list: Array[Enemy] = []

signal enemy_list_updated

func _ready() -> void:
	Globals.enemy_handler = self
	await get_tree().process_frame
	await get_tree().process_frame
	# spawn_enemies()
	Globals.player.sound_created.connect(check_enemy_detect_player_by_sound)


func add_enemy_to_list(enemy: Enemy) -> void:
	enemy_list.append(enemy)

func remove_enemy_from_list(enemy: Enemy) -> void:
	enemy_list_updated.emit()
	if enemy in enemy_list:
		enemy_list.erase(enemy)

func check_enemy_detect_player_by_sound(player_pos: Vector2, sound_loudness: float) -> void:
	for enemy in enemy_list:
		var distance_to_player = player_pos.distance_to(enemy.global_position)
		if distance_to_player < sound_loudness + enemy.hearing_sensitivity:
			# TODO: Implement all enemy Alerted state here
			enemy.alerted(player_pos)
			# print("Enemy {0} alerted by player noise from {1} units!".format([enemy.name, distance_to_player]))

func spawn_enemies():
	var room_data = Globals.map_generator.get_current_room_data()

	# Load existing data
	if not room_data.is_new:
		for elem in room_data.room_enemy_data:
			var enemy_id = elem['id']
			var enemy_global_position = elem['global_position']
			var enemy_is_elite = elem['is_elite']
			var enemy_scene = Globals.enemy_scene_database[enemy_id - 1]

			var enemy_inst: Enemy = enemy_scene.instantiate()
			enemy_inst.is_elite = enemy_is_elite

			# Rat monarch
			if elem.has("splitted_time"):
				enemy_inst.load_splitted_form(elem["splitted_time"])


			# Add child to root node
			add_child(enemy_inst)
			add_enemy_to_list(enemy_inst)
			enemy_inst.global_position = enemy_global_position

		return

	# Spawn new
	for area: SpawnArea in spawn_areas.get_children():
		# var spawn_mob = randf() < 0.5
		var spawn_mob = true
		if spawn_mob:
			var spawns = randi_range(min_spawns_per_area, max_spawns_per_area)
			area.spawn_batch(spawns)

func clear_room():
	for child in spawn_areas.get_children():
		child.queue_free()
	for child in enemy_list:
		child.queue_free()
	enemy_list = []
