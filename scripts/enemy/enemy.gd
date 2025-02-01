class_name Enemy
extends CharacterBody2D

var attack_damage: int
@export var health: int:
	set(value):
		print(value)
		if health > value:
			damage()
		health = value
		if health <= 0:
			die()

func damage() -> void:
	# Override in subclass
	# Play any damaged effects/animations
	pass

func die() -> void:
	# Override in subclass
	# Play death effects then die
	queue_free()
