class_name DCF_Item
extends Resource

enum Rarity {COMMON, UNCOMMON, RARE, LEGENDARY}

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
	SPAGHETTI_BOLOGNAISE = 2000,
	# Other > 3000
	CHEESE_PIZZA = 3001,
	TOPPINGLESS_PIZZA = 3002
}

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
@export var item_id: ItemId # Used for locating it in file
@export var item_name: String # Name in-game
@export var description: String
@export var weight: float
# On UI display, we can convert quality into Common, Uncommon, Rare, etc 
#@export_range(1, 100, 1) var quality: int 
@export var rarity: Rarity
