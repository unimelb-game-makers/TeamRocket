class_name DCF_Item
extends Resource

@export var texture: Texture2D
@export var item_name: String
@export var description: String
@export var weight: float
# On UI display, we can convert quality into Common, Uncommon, Rare, etc 
@export_range(1, 100, 1) var quality: int 
