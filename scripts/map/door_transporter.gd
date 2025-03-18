extends Area2D
class_name DoorArea

# North (0), East (1), South (2), West (3)
@export_range(0, 3, 1) var direction = 0

signal go_to_room(dir)

## Which room this door leads into (set by script)
#var target_room: PackedScene

var door_direction: Vector2

func _on_area_entered(area: Area2D) -> void:
	go_to_room.emit(door_direction)
	#get_tree().change_scene_to_packed(target_room)
