extends Resource
class_name RoomData

# Note: What to save
# Enemy - type, location
# Environment - Map room type, PoI spawned
# Interactable - Crates, barrel (destroyed or not)
# Item - Items on ground (optional), items inside crates

var room_scene: PackedScene # Correct room template to generate

var is_new = true
var medium_poi_scene: PackedScene
var medium_poi_location: Vector2
var large_poi_scene: PackedScene
var large_poi_location: Vector2

var coord: Vector2

var room_enemy_data = []

func save_enemies(enemies: Array[Enemy]):
	for elem in enemies:
		# Save enemy type and location here
		room_enemy_data.append(elem.get_save_data())

func save():
	save_enemies(Globals.enemy_handler.enemy_list)


func get_room_id():
	return "room_%d_%d" % [coord[0], coord[1]]
