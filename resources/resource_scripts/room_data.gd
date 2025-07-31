extends Resource
class_name RoomData

# Note: What to save
# Enemy - type, location
# Environment - Map room type, PoI spawned
# Interactable - Crates, barrel (destroyed or not)
# Item - Items on ground (optional), items inside crates

@export var roomScene: PackedScene # Correct room template to generate
@export var poi_path: String
@export var poi_size: String

var enemyDict: Dictionary = {}

func save_enemies(room_coords: Vector2, enemies: Array[Enemy]):
	var enemySaveDataArray = []
	for elem in enemies:
		# Save enemy type and location here
		enemySaveDataArray.append(elem.get_save_data())
	enemyDict[get_room_id(room_coords)] = enemySaveDataArray

func save(room_coords: Vector2):
	save_enemies(room_coords, Globals.enemy_handler.enemy_list)


func get_room_id(coords: Vector2):
	return "room_%d_%d" % [coords[0], coords[1]]