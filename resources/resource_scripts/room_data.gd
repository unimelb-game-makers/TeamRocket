extends Resource
class_name RoomData

# Note: What to save
# [DONE] Enemy - type, location
# [DONE] Environment - Map room type, PoI spawned
# Interactable - Crates (included its items), barrel (destroyed or not)
# Item on ground (optional)

var room_scene: PackedScene # Correct room template to generate

var is_new = true
var is_unique_poi = false

var unique_poi_scene: PackedScene
var unique_poi_location: Vector2
var unique_poi_id: PlaceablePOI.UniquePoiEnum
var medium_poi_scene: PackedScene
var medium_poi_location: Vector2
var large_poi_scene: PackedScene
var large_poi_location: Vector2

var coord: Vector2

var room_enemy_data = []
var room_interactable_data = []

func save_enemies(enemies: Array[Enemy]):
	room_enemy_data = []
	for elem in enemies:
		# Save enemy type and location here
		room_enemy_data.append(elem.get_save_data())

func save_interactables(interactables: Array[Node]):
	room_interactable_data = []
	for elem in interactables:
		if elem.has_method("get_save_data"):
			room_interactable_data.append(elem.get_save_data())

func save_room_data():
	print("Save data at ", coord)
	save_enemies(Globals.enemy_handler.enemy_list)
	save_interactables(Globals.interactable_handler.interactable_holder.get_children())


func get_room_id():
	return "room_%d_%d" % [coord[0], coord[1]]
