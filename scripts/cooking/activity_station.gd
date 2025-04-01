extends Area2D

@export var activity: PackedScene
@onready var cooking_scene: CookingScene = $CanvasLayer/CookingScene

func reset_cooking():
	cooking_scene.reset()

func interact():
	if (cooking_scene.visible):
		cooking_scene.hide()
	else:
		reset_cooking()
		cooking_scene.show()

func _on_cooking_scene_complete(output: Variant) -> void:
	cooking_scene.hide()

func _on_body_exited(body: Node2D) -> void:
	reset_cooking()
	cooking_scene.hide()
