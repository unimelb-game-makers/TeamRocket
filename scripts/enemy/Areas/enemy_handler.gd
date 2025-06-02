extends Node2D
class_name EnemyHandler

@export var min_spawns_per_area: int = 1
@export var max_spawns_per_area: int = 1

@onready var spawn_areas: Node = $SpawnAreas

var enemy_list: Array[Enemy] = []

signal enemy_list_updated

func _ready() -> void:
	Globals.enemy_handler = self
	spawn_enemies()
	await get_tree().process_frame
	await get_tree().process_frame
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
	for area in spawn_areas.get_children():
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
