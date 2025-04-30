class_name Dish
extends Item

# Final output class of item which player can eat or serve

@export var effects: Array[Item.Effects]
@export var ingredients: Array[Ingredient.IngredientType]

func save() -> Dictionary:
	var item_dict = super()
	item_dict["item_name"] = item_name
	item_dict["item_type"] = ItemType.DISH
	item_dict["effects"] = effects
	item_dict["ingredients"] = ingredients
	item_dict["texture_path"] = texture.resource_path
	item_dict["description"] = description
	item_dict["weight"] = weight
	item_dict["rarity"] = rarity
	return item_dict

static func parse_dict(item_dict: Dictionary) -> Item:
	var dish: Dish = Dish.new()
	dish.item_name = item_dict["item_name"]
	dish.item_id = item_dict["item_id"]
	dish.texture = load(item_dict["texture_path"])
	dish.description = item_dict["description"]
	dish.weight = item_dict["weight"]
	dish.rarity = item_dict["rarity"]
	#dish.effects = item_dict["effects"]
	#dish.ingredients = item_dict["ingredients"]
	return dish
