extends Node2D

var next_scene = preload("res://scenes/cooking/PourBroth.tscn")

var limit
var num_other_side = 0

func _ready():
	limit = $Cabbage.leaves_limit

func _on_timer_gameover() -> void:
	pass # Replace with function body.

func _on_next_next_scene() -> void:
	get_tree().change_scene_to_packed(next_scene)

func _on_cabbage_leaf_spawned(l: CabbageLeaf) -> void:
	l.placed_down.connect(Callable(self, "check_leaf_position"))

func check_leaf_position(pos: Vector2):
	# Does not account for leaves moved back to left side after placing on right side
	if pos.x > $Divider.position.x:
		num_other_side += 1
	
	if num_other_side == limit:
		$Next.visible = true
		$Timer.pause()
