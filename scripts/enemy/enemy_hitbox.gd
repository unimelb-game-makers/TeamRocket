extends Area2D
class_name EnemyHitbox


var enemy: Enemy

func _ready() -> void:
	enemy = get_parent()

func damage(value: int):
	if enemy != null:
		enemy.damage(value)
