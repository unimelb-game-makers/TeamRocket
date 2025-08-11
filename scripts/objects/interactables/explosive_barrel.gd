extends StaticBody2D

@export var fire_scene: PackedScene
@export var explosion_damage: int = 100

@onready var explosion_range: Area2D = $ExplosionRange

func damage(_value: int):
	var fire_inst = fire_scene.instantiate()
	Globals.interactable_handler.interactable_holder.add_child(fire_inst)
	fire_inst.global_position = global_position
	# TODO: Play explosive VFX and SFX here
	explosion()
	queue_free()

func _on_environment_hitbox_damaged(value: int) -> void:
	damage(value)


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
