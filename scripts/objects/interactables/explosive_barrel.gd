extends StaticBody2D

@export var fire_scene: PackedScene
@export var explosion_damage: int = 100

@onready var explosion_range: Area2D = $ExplosionRange
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var exploded = false

func damage(_value: int, _damage_source_position: Vector2 = Vector2.ZERO):
	if exploded:
		return
	exploded = true
	var fire_inst = fire_scene.instantiate()
	Globals.interactable_handler.interactable_holder.call_deferred("add_child", fire_inst)
	fire_inst.global_position = global_position
	audio_player.play()
	# TODO: Play explosive VFX here
	call_deferred("explosion")
	visible = false
	for child in get_children():
		if child is Area2D:
			child.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(1).timeout
	call_deferred("queue_free")

func _on_environment_hitbox_damaged(value: int, damage_source_position: Vector2) -> void:
	damage(value, damage_source_position)


func explosion():
	for area in explosion_range.get_overlapping_areas():
		if area.has_method("damage"):
			area.damage(explosion_damage)

	for body in explosion_range.get_overlapping_bodies():
		if body.has_method("damage"):
			body.damage(explosion_damage)

func get_save_data():
	return {
		"name": "explosive_barrel",
		"type": "interactable",
		"global_position": global_position,
	}
