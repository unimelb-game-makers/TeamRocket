extends Area2D

@onready var sprite: Sprite2D = $Sprite

@export var item: Item
@export var amount: int = 1

func _ready() -> void:
	set_item()

func delete_item() -> void:
	queue_free()
	
func set_item() -> void:
	sprite.texture = item.texture

func interact() -> void:
	InventoryGlobal.add_item(item, amount)
	delete_item()
