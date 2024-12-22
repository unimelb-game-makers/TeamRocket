class_name Item
extends Resource

enum Rarity {COMMON, UNCOMMON, RARE, LEGENDARY}

@export var texture: Texture2D
@export var item_name: String
@export var description: String
@export var weight: float
@export var rarity: Rarity

func is_item(item: Item) -> bool:
	if item_name == item.item_name:
		return true
	return false
