extends Node2D

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
## then enter one "B" in '2' and '3' each.
@export var sockets: Array[String] = [
	"",
	"", # Do not enter the values here! Select the node with this script attached
	"", # and enter the values in the Inspector
	""
]

## Chance of this room appearing in the map. 1 = least likely, 5 = most likely.
@export_range(1,5) var room_weighting: int = 1

var doors: Array

func _ready() -> void:
	
	# Verify each socket only has 1 character
	for i in sockets:
		assert(len(i) <= 1, "Socket must have 0 or 1 characters")
	
	# Get all door areas and connect them to scene transitioner
	doors = get_tree().get_nodes_in_group("DoorArea")
