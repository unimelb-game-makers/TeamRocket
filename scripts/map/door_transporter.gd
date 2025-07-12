extends Area2D
class_name DoorArea

signal go_to_room(dir)
signal player_exit

var door_direction: Vector2
# True if player enters the room through this door. Blocks _on_area_entered.
var is_entered: bool = false

# If player spawns on this door, is_entered will be true.
func _on_area_exited(_area: Area2D) -> void:
	is_entered = false

func _on_body_entered(_body: Node2D) -> void:
	if not is_entered:
		go_to_room.emit(door_direction)

func _on_body_exited(_body: Node2D) -> void:
	player_exit.emit()
