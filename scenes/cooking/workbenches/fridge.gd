extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var fridge_ui: Control = $CanvasLayer/FridgeUI

func _ready() -> void:
	sprite.material.set_shader_parameter("outline_color", Color.YELLOW)

func reset_display():
	fridge_ui.reset()

func interact():
	if (fridge_ui.visible):
		fridge_ui.hide()
	else:
		reset_display()
		fridge_ui.show()


func _on_body_exited(_body: Node2D) -> void:
	reset_display()
	fridge_ui.hide()
	sprite.material.set_shader_parameter("outline_color", Color.YELLOW)


func _on_body_entered(_body: Node2D) -> void:
	sprite.material.set_shader_parameter("outline_color", Color.GREEN)
