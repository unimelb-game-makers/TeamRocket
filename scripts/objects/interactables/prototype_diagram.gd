extends Area2D

@onready var recipe_ui = $PrototypeDiagram/UI

func interact():
	recipe_ui.visible = not recipe_ui.visible

func _on_body_exited(body: Node2D) -> void:
	recipe_ui.hide()
