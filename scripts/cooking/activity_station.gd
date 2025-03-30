extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var cooking_scene: CookingScene = $CanvasLayer/CookingScene


func _ready() -> void:
	sprite.material.set_shader_parameter("outline_color", Color.YELLOW)

func reset_cooking():
	cooking_scene.reset()

func interact():
	if cooking_scene.activity_is_in_progress:
		return
	if (cooking_scene.visible):
		cooking_scene.hide()
	else:
		reset_cooking()
		cooking_scene.show()

func _on_cooking_scene_complete(_output: Variant) -> void:
	cooking_scene.hide()

func _on_body_exited(_body: Node2D) -> void:
	reset_cooking()
	cooking_scene.hide()
	sprite.material.set_shader_parameter("outline_color", Color.YELLOW)


func _on_body_entered(_body: Node2D) -> void:
	sprite.material.set_shader_parameter("outline_color", Color.GREEN)
