extends CenterContainer

@onready var inventory_container: GridContainer = $ScrollContainer/ItemContainer
signal item_selected(item: Item, amount: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inventory_container.update_inventory_list()

func select_item(item: Item, amount: int):
	item_selected.emit(item, amount)

func update_inventory_list() -> void:
	inventory_container.update_inventory_list()
