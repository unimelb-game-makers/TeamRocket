extends Area2D
class_name DoorArea

# North (0), East (1), South (2), West (3)
@export_range(0, 3, 1) var direction = 0

signal go_to_room(dir)
signal player_exit

var door_direction: Vector2
# True if player enters the room through this door. Blocks _on_area_entered.
var is_entered: bool = false 

# If player spawns on this door, is_entered will be true.
func _on_area_exited(area: Area2D) -> void:
	is_entered = false

func _on_body_entered(body: Node2D) -> void:
	if not is_entered:
		print("Entered door is in direction: " + str(door_direction))
		print("------------------")
		go_to_room.emit(door_direction)

func _on_body_exited(body: Node2D) -> void:
	player_exit.emit()
