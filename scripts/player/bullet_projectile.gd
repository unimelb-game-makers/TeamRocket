extends Node2D
class_name BulletProjectile

@export var speed: float = 5000

var direction = Vector2.ZERO
var damage = 0
var used = false

func init(_direction: Vector2, _damage: int):
	direction = _direction
	damage = _damage
	rotation = direction.angle()

func _physics_process(delta):
	global_position += direction * speed * delta


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if used:
		queue_free()
		return

	if area is EnemyHitbox:
		area.damage(damage, global_position)
		used = true
	elif area.has_method("damage"):
		area.damage(damage, global_position)
		used = true
	queue_free()


func _on_hurt_box_body_entered(body: Node2D) -> void:
	if used:
		queue_free()
		return

	if body.has_method("damage"):
		body.damage(damage, global_position)
		used = true
	queue_free()


func _on_life_timer_timeout() -> void:
	queue_free()
