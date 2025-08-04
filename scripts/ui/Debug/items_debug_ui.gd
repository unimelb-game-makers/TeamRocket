extends Panel

@onready var grid_container: GridContainer = $ScrollContainer/GridContainer

@export var items_display: Array[Item]
@export var food_slot_scene: PackedScene

func _ready() -> void:
	for i in range(items_display.size()):
		var inst: FoodSlot = food_slot_scene.instantiate()
		grid_container.add_child(inst)
		inst.set_ingredient(items_display[i])
		inst.index = i
		inst.food_removed.connect(give_food)

func give_food(index) -> void:
	InventoryGlobal.add_item(items_display[index], 1)
