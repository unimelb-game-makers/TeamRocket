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
@export var possible_medium_poi_spawn: Array[PackedScene]
@export var player_spawn: Marker2D
@export var medium_poi_spawn: Marker2D
@export var large_poi_spawn: Marker2D

@export_group("Map setting")
@export var enemy_spawn_nodes: Array[Node2D] = []
@export var map_loot_table: Array[Item] = []


@onready var navigation_region: NavigationRegion2D = $NavigationRegion2D

var spawned_pois: Array[PlaceablePOI] = []

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
	if medium_poi_spawn != null and possible_medium_poi_spawn.size() > 0:
		var chosen_medium_poi = possible_medium_poi_spawn.pick_random()
		var inst = chosen_medium_poi.instantiate()
		add_child(inst)
		inst.global_position = medium_poi_spawn.global_position
		spawned_pois.append(inst)


func get_player_spawn_pos() -> Vector2:
	return player_spawn.global_position


func get_enemy_spawns():
	var res = []
	for elem in spawned_pois:
		res.append_array(elem.get_enemy_spawns())
	return res

func get_interactables():
	var res = []
	for elem in spawned_pois:
		res.append_array(elem.get_interactables())
	return res

func get_enemies():
	var res = []
	for elem in spawned_pois:
		res.append_array(elem.get_enemies())
	return res
