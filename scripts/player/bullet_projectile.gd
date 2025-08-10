extends Node2D
class_name BulletProjectile

@export var bullet_impact_scene: PackedScene
@export var speed: float = 5000

@onready var hurt_box: Area2D = $HurtBox
@onready var bullet_sprite: Sprite2D = $Sprite2D

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
		return

	if area is EnemyHitbox:
		area.damage(damage, global_position)
		used = true
	elif area.has_method("damage"):
		area.damage(damage, global_position)
		used = true
	destroyed()


func _on_hurt_box_body_entered(body: Node2D) -> void:
	if used:
		return

	if body.has_method("damage"):
		body.damage(damage, global_position)
		used = true
	destroyed()


func destroyed():
	var impact_inst = bullet_impact_scene.instantiate()
	get_tree().get_root().add_child(impact_inst)
	impact_inst.global_position = global_position
	bullet_sprite.visible = false
	speed = 0
	used = true
	await get_tree().create_timer(0.25).timeout
	queue_free()


func _on_life_timer_timeout() -> void:
	destroyed()
