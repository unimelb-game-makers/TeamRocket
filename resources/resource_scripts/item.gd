extends Resource

enum Rarity {COMMON, UNCOMMON, RARE, LEGENDARY}

# When add new item, use a big number faraway from other number,
# so you have the space to add something else related to them
# near them in the list.
# If you change the number, remember to fix them in the Resource file.
enum ItemId {
	NONE,
	DEFAULT,
	# Raw material = 10-900
	CARROT = 10,
	CARROT_CHOPPED = 11,
	BEEF_MINCE_RAW = 20,
	BEEF_MINCE_COOKED = 21,
	ONION = 30,
	ONION_CHOPPED = 31,
	TOMATO = 40,
	TOMATO_CHOPPED = 41,
	SPAGHETTI_RAW = 50,
	SPAGHETTI_COOKED = 51,
	# Middle material = 1000-1900
	BOLOGNAISE_SAUCE = 1000,
	# Completed recipe = 2000-2900
	SPAGHETTI_BOLOGNAISE = 2000
	# Other > 3000
}

@export var item_id: ItemId
@export var texture: Texture2D
@export var item_name: String
@export var description: String
@export var weight: float
@export var rarity: Rarity

func is_item(item: Item) -> bool:
	if item_name == item.item_name:
		return true
	return false
