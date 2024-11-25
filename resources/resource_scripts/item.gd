class_name Item
extends Resource

enum Rarity {COMMON, UNCOMMON, RARE, LEGENDARY}

@export var texture: Image
@export var item_name: String
@export var weight: float
@export var rarity: Rarity
