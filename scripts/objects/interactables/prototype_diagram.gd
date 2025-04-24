extends Area2D

@onready var recipe_ui = $PrototypeDiagram/UI
@onready var sprite: Sprite2D = $PrototypeDiagram

func _ready():
	sprite.material.set_shader_parameter("outline_color", Color.YELLOW)

func interact():
	recipe_ui.visible = not recipe_ui.visible

func _on_area_exited(_area: Area2D) -> void:
	recipe_ui.hide()
	sprite.material.set_shader_parameter("outline_color", Color.YELLOW)

func _on_area_entered(_area: Area2D) -> void:
	sprite.material.set_shader_parameter("outline_color", Color.GREEN)
