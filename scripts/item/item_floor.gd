extends Area2D

@onready var sprite: Sprite2D = $Sprite

@export var item: Item
@export var amount: int = 1

func _ready() -> void:
	sprite.material.set_shader_parameter("thickness", 0)
	set_item()

func delete_item() -> void:
	queue_free()
	
func set_item() -> void:
	sprite.texture = item.texture

func interact() -> void:
	InventoryGlobal.add_item(item, amount)
	delete_item()

func _on_area_exited(_area: Area2D) -> void:
	sprite.material.set_shader_parameter("thickness", 0)


func _on_area_entered(_area: Area2D) -> void:
	sprite.material.set_shader_parameter("thickness", 5)
