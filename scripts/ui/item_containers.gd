extends VBoxContainer

@export var item_container_scene: PackedScene
signal selected_item(item, amount)

func update_inventory_list():
	# KILL ALL CHILDREN
	for child in get_children():
		child.queue_free()
	# Render Inventory Items
	for item in InventoryGlobal.get_inventory():
		var item_label = item_container_scene.instantiate()
		item_label.item = item
		item_label.amount = InventoryGlobal.get_inventory()[item]
		item_label.item_selected.connect(select_item)
		item_label.item_dropped.connect(drop_item)
		add_child(item_label)

func select_item(item, amount):
	selected_item.emit(item, amount)

func drop_item(item, amount):
	InventoryGlobal.drop_item(item, amount)
