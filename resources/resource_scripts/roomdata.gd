class_name RoomData
extends Resource

@export var roomscene: PackedScene # Correct room template to generate
@export var enemies: Array[PackedScene]
@export var poi_path: String
@export var poi_size: String

func save_enemies() -> Dictionary:
	var enemiesdict = {}
	for i in enemies:
		var curr = {}
	return enemiesdict

func save() -> Dictionary:
	var roomdatadict = {}
	roomdatadict["roomscenepath"] = roomscene.resource_path
	roomdatadict["enemies"] = save_enemies()
	
	return roomdatadict

static func parse_dict(item_dict: Dictionary):
	#var dish: Dish = Dish.new()
	#dish.item_name = item_dict["item_name"]
	#dish.item_id = item_dict["item_id"]
	#dish.texture = load(item_dict["texture_path"])
	#dish.description = item_dict["description"]
	#dish.weight = item_dict["weight"]
	#dish.rarity = item_dict["rarity"]
	#dish.effects = []
	#for effect in item_dict["effects"]:
		#dish.effects.append(effect as Item.Effects)
	#dish.ingredients = []
	#for ingredient in item_dict["ingredients"]:
		#dish.ingredients.append(Item.load_item(ingredient))
	#return dish
	pass
