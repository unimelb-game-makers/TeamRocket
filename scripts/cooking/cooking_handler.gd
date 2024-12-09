extends Control

var current_scene
var scene_active = false

func init_activity(activity) -> void:
	if (not scene_active):
		visible = true
		scene_active = true
		var cooking_scene = activity.instantiate()
		add_child(cooking_scene)
		cooking_scene.complete.connect(finish)
		current_scene = get_child(0)
	else:
		scene_active = false
		visible = false
		if (get_child(0)):
			get_child(0).queue_free()
	
func finish() -> void:
	current_scene.queue_free()

func _on_inventory_container_selected_item(item: Variant, amount: Variant) -> void:
	if (scene_active):
		current_scene.add_item(item)
