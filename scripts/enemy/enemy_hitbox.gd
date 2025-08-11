extends Area2D
class_name EnemyHitbox


var enemy: Enemy

func _ready() -> void:
	enemy = get_parent()

func damage(value: int, damage_source_position: Vector2 = Vector2.ZERO):
	if enemy != null:
		enemy.damage(value, damage_source_position)
