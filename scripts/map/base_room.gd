extends Node2D
class_name BaseRoom

# A direction can have no doors
# Each direction can have 1 or more doors leading to the same room

const NORTH = 0
const EAST = 1
const SOUTH = 2
const WEST = 3

# Socket Rules. Each socket can only have 1.
const BLANK = "A" # No room can be attached to this socket.
const DOOR = "B"  # There is a door in this direction.

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
@export_range(1,5) var room_weighting: int = 1

@export var doors: Array[Area2D] = [] # Door scenes, cant get by get_tree
@export var spawn: Node2D
#const PLAYER = preload("res://scenes/player/Player.tscn")

#var player: Player

func _ready() -> void:
	
	# Verify each socket only has 1 character
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
