class_name Item
extends Resource

# Base Class for Item in game system

enum ItemType {ITEM, INGREDIENT, DISH}

enum Rarity {COMMON, UNCOMMON, RARE, LEGENDARY}

enum Quality {
	RUINED, ## Unusable essentially
	POOR, ## Left for too long, bad cooking
	NORMAL, ## What you typically find
	GOOD, ## The uncommon finds
	EXCELLENT, ## The rare finds
	PERFECT ## Super rare finds, hard to maintain when using it
}

# Effects should have
# - Effect Level 
# - Duration: X amount of seconds, Per Day, Permanent

# Should be using straight StatusEffect Resource for this part but
# Alpha deadline and all that, I don't want to rework the save system atm
enum Effects {
	# Good Effects
	LETHALITY_PERM,
	LETHALITY_TEMP,
	HEALTH_PERM,
	HEALTH_TEMP,
	HEAL_1,
	VISION,
	SPEED_PERM,
	SPEED_TEMP,
	DASH_COOLDOWN,
	SILENCE,
	
	# Eldritch Effects
	UNKNOWN1,
	UNKNOWN2,
	
	# Bad Effects
	SLOW,
	POISON,
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
@export var quality: Quality = Quality.NORMAL

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

func _to_string() -> String:
	#var name :String = item_name + "(Quality: " + str(round(quality)) + ")" + "(" + str(self.get_instance_id()) + ")"
	var name: String = item_name + "(Quality: " + _quality_to_string(self.quality) + ")"
	return name

func _quality_to_string(quality: Quality) -> String:
	match quality:
		Quality.RUINED:
			return "Ruined"
		Quality.POOR:
			return "Poor"
		Quality.NORMAL:
			return "Normal"
		Quality.GOOD:
			return "Good"
		Quality.EXCELLENT:
			return "Excellent"
		Quality.PERFECT:
			return "Perfect"
		_:
			return "Unknown"
