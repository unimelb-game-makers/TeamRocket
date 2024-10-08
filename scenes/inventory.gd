extends VBoxContainer

func update_inventory():
	# KILL ALL CHILDREN
	for child in get_children():
		child.queue_free()
	# Render Inventory Items
	for item in Inventory_Global.get_inventory():
		var item_label = Label.new()
		item_label.text = item
		add_child(item_label)

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("inventory")):
		visible = not visible
