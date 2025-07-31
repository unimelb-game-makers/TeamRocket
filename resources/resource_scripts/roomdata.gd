extends Resource
class_name RoomData

@export var roomScene: PackedScene # Correct room template to generate
@export var poi_path: String
@export var poi_size: String

func save_enemies(enemies: Array[Enemy]) -> Dictionary:
	var enemyDict = {}
	for elem in enemies:
		# Save enemy type and location here
		pass
	return enemyDict

func save() -> Dictionary:
	var roomDataDict = {}
	roomDataDict["roomScenePath"] = roomScene.resource_path
	
	return roomDataDict

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
