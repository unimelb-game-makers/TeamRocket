class_name Enemy
extends CharacterBody2D

var attack_damage: int
@export var health: int:
	set(value):
		if health > value:
			damage()
		health = value
		if health <= 0:
			die()

func damage() -> void:
	# Override in subclass
	# Play any damaged effects/animations
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.8, 0.5, 0.5), 0.2)
	tween.tween_property(self, "modulate", Color(1,1,1), 0.2)

func die() -> void:
	# Override in subclass
	# Play death effects then die
	queue_free()
