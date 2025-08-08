extends Node2D
class_name ProceduralRoom

# A direction can have no doors
# Each direction can have 1 or more doors leading to the same room

const NORTH = 0
const EAST = 1
const SOUTH = 2
const WEST = 3

# Socket Rules. Each socket can only have 1.
const BLANK = "A" # No room can be attached to this socket.
const DOOR = "B" # There is a door in this direction.

@export var room_name: String

@export_group("Generation setting")
## In the order of NESW, enter the appropriate socket in the array in the Inspector.
## For example, if this room has 1 door in the South and 2 doors in the West,
## then replace "A" with one "B" in '2' and '3' each.
@export var sockets: Array[String] = [
	"A",
	"A", # Do not replace the value here! Select the node with this script attached
	"A", # and enter the value in the Inspector
	"A"
]
## Chance of this room appearing in the map. 1 = least likely, 5 = most likely.
@export_range(1, 5) var room_weighting: int = 1
## 4 items max, in North, East, South, West order
@export var doors: Array[Area2D] = [] # Door scenes, cant get by get_tree

@export_group("Point of Interest")
@export var select_first_medium_poi: bool = false ## When true, generate the POI in the 0th index, for debugging.
@export var possible_medium_poi_spawn: Array[PackedScene]
@export var select_first_large_poi: bool = false ## When true, generate the POI in the 0th index, for debugging.
@export var possible_large_poi_spawn: Array[PackedScene]
@export var player_spawn: Marker2D
@export var medium_poi_spawn: Marker2D
@export var large_poi_spawn: Marker2D

@export_group("Map setting")
@export var map_loot_table: Array[Item] = []

@onready var navigation_region: NavigationRegion2D = $NavigationRegion2D
@onready var interactable_holder: Node2D = $InteractableHolder

var spawned_pois: Array[PlaceablePOI] = []
var coord: Vector2

func _ready() -> void:
	# Verify each socket only has 1 character
	print("This room is ", room_name)
	for i in sockets:
		assert(len(i) <= 1, "Socket must have 1 character")

func connect_doors(directions: Array):
	for i in range(len(doors)):
		if (doors[i] == null):
			continue
		print("Connect incoming direction: " + str(directions[i]))
		doors[i].door_direction = directions[i]

func get_door_by_direction(incoming: Vector2):
	for i in doors:
		if i == null:
			continue
		if i.door_direction == incoming:
			return i

func has_poi_markers():
	if medium_poi_spawn != null and large_poi_spawn != null:
		return true
	return false

func spawn_poi():
	var room_data = Globals.map_generator.get_current_room_data()

	# Load existing data
	if not room_data.is_new:
		if room_data.medium_poi_scene:
			var inst = room_data.medium_poi_scene.instantiate()
			add_child(inst)
			inst.global_position = room_data.medium_poi_location
			inst.map_room = self
			spawned_pois.append(inst)

		if room_data.large_poi_scene:
			var inst = room_data.large_poi_scene.instantiate()
			add_child(inst)
			inst.global_position = room_data.large_poi_location
			inst.map_room = self
			spawned_pois.append(inst)

		return

	# Spawn new
	if medium_poi_spawn != null and possible_medium_poi_spawn.size() > 0:
		var chosen_medium_poi = possible_medium_poi_spawn.pick_random()
		if select_first_medium_poi: ## Overrides
			push_warning("DEBUG OVERRIDE SELECTION ON IN ", self)
			
		var inst = chosen_medium_poi.instantiate()
		add_child(inst)
		inst.global_position = medium_poi_spawn.global_position
		inst.map_room = self
		spawned_pois.append(inst)
		# Save room data
		room_data.medium_poi_scene = chosen_medium_poi
		room_data.medium_poi_location = medium_poi_spawn.global_position

	if large_poi_spawn != null and possible_large_poi_spawn.size() > 0:
		var chosen_large_poi = possible_large_poi_spawn.pick_random()
		if select_first_large_poi: ## Overrides
			push_warning("DEBUG OVERRIDE SELECTION ON IN ", self)
			chosen_large_poi = possible_large_poi_spawn[0]
		var inst = chosen_large_poi.instantiate()
		add_child(inst)
		inst.global_position = large_poi_spawn.global_position
		inst.map_room = self
		spawned_pois.append(inst)
		# Save room data
		room_data.large_poi_scene = chosen_large_poi
		room_data.large_poi_location = large_poi_spawn.global_position


func get_player_spawn_pos() -> Vector2:
	return player_spawn.global_position


func generate_loot_for_container():
	for elem in spawned_pois:
		elem.generate_loot_for_container()

func get_enemy_spawns():
	# TODO: Add spawns from map room too
	var res = []
	for elem in spawned_pois:
		res.append_array(elem.get_enemy_spawns())
	return res

func get_interactables():
	var res = interactable_holder.get_children()
	for elem in spawned_pois:
		res.append_array(elem.get_interactables())
	return res

func get_enemies():
	# TODO: Add enemies from map room too
	var res = []
	for elem in spawned_pois:
		res.append_array(elem.get_enemies())
	return res
