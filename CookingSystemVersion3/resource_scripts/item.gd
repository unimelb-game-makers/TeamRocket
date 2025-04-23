class_name Item
extends Resource

# Base Class for Item in game system

enum ItemType {ITEM, INGREDIENT, DISH}

enum Rarity {COMMON, UNCOMMON, RARE, LEGENDARY}

enum Effects {
	HP1,
	HP2,
	HP3,
	ATK1,
	ATK2,
	CHEESETOUCH,
	COOLPORKINESS,
	SKEWERINGDELIGHT
}

@export var texture: Texture2D
@export var texture_id: Texture2D # The name of the texture in file system, used for locating it in file
@export var item_name: String # Name in-game
# Do we need an item id if we just save the whole thing?
@export var description: String
@export var weight: float
# On UI display, we can convert quality into Common, Uncommon, Rare, etc 
#@export_range(1, 100, 1) var quality: int 
@export var rarity: Rarity

func save() -> Dictionary:
	var item_dict = {}
	item_dict["item_name"] = item_name
	item_dict["texture_id"] = texture_id
	item_dict["description"] = description
	item_dict["weight"] = weight
	item_dict["rarity"] = rarity
	item_dict["item_type"] = ItemType.ITEM
	return item_dict
	
static func load(dict: Dictionary) -> Item:
	match dict["item_type"]:
		ItemType.ITEM: 
			return parse_dict(dict)
		ItemType.INGREDIENT:
			return Ingredient.parse_dict(dict)
		ItemType.DISH:
			return Dish.parse_dict(dict)
	return
		
static func parse_dict(dict: Dictionary):
	
	return
