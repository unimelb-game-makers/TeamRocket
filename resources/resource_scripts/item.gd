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
@export var item_id: String # Item id used to load item resources from file (if they exist)
@export var item_name: String # Name in-game
# Do we need an item id if we just save the whole thing?
@export var description: String
@export var weight: float
# On UI display, we can convert quality into Common, Uncommon, Rare, etc 
@export var rarity: Rarity
# Quality ranging from 0 to 100
# If quality is 0, do not need to display or save
@export_range(0, 100, 1) var quality: int 

func save() -> Dictionary:
	var item_dict = {}
	item_dict["item_id"] = self.resource_path
	item_dict["item_type"] = ItemType.ITEM
	return item_dict
	
func equals(other_item: Item):
	if (other_item.item_name == item_name):
		return true
	
static func load_item(dict: Dictionary) -> Item:
	match int(dict["item_type"]):
		ItemType.ITEM: 
			return parse_dict(dict)
		ItemType.INGREDIENT:
			return parse_dict(dict)
		ItemType.DISH:
			return Dish.parse_dict(dict)
	return

static func parse_dict(item_dict: Dictionary) -> Item:
	var item: Item = load(item_dict["item_id"])
	return item
