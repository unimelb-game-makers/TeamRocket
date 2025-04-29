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
@export var item_id: String # Item id is used for both comparison and loading textures from ref
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
	item_dict["item_id"] = item_id
	item_dict["texture_path"] = texture.resource_path
	item_dict["description"] = description
	item_dict["weight"] = weight
	item_dict["rarity"] = rarity
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
			return Ingredient.parse_dict(dict)
		ItemType.DISH:
			return Dish.parse_dict(dict)
	return
		
static func parse_dict(item_dict: Dictionary) -> Item:
	var item = Item.new()
	item.item_name = item_dict["item_name"]
	item.item_id = item_dict["item_id"]
	item.texture = load(item_dict["texture_path"])
	item.description = item_dict["description"]
	item.weight = item_dict["weight"]
	item.rarity = item_dict["rarity"]
	return item
