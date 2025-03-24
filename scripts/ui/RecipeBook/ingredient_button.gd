extends Button

var item: Item
signal item_selected(item)
	
func update_icon():
	icon = item.texture

func _on_pressed() -> void:
	item_selected.emit(item)
