extends Control

var current_scene
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func init_activity(activity) -> void:
	var cooking_scene = activity.instantiate()
	add_child(cooking_scene)
	cooking_scene.complete.connect(finish)
	current_scene = get_child(0)
	
func finish() -> void:
	current_scene.queue_free()
	print("Activity Finished")
