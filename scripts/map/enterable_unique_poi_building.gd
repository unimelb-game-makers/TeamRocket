extends StaticBody2D

@export var poi_id: PlaceablePOI.UniquePoiEnum
@export var interior_scene: PackedScene

var door_usable = false


func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	door_usable = true

func _on_entry_body_entered(_body: Node2D) -> void:
	if not door_usable:
		return
	Globals.map_generator.enter_unique_poi_room(interior_scene, poi_id)


func _on_entry_body_exited(_body: Node2D) -> void:
	return
