class_name CookingActivityStation
extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var cooking_scene: CookingScene = $CanvasLayer/CookingScene

signal is_interacting_with(state: bool)

func _ready() -> void:
	sprite.material.set_shader_parameter("outline_color", Color.YELLOW)

func reset_cooking():
	cooking_scene.reset()

func interact():
	if cooking_scene.activity_is_in_progress: # Essentialy means interact is called but doesnt do anything when minigame is running
		return
	if (cooking_scene.visible): # When the UI is open
		exit_cooking()
	else:
		reset_cooking()
		cooking_scene.show()
		emit_signal("is_interacting_with", true)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and (cooking_scene.visible):
		exit_cooking()
		get_viewport().set_input_as_handled()

func exit_cooking() -> void:
	cooking_scene.hide() # BUG: This doesnt disable the minigame
	emit_signal("is_interacting_with", false)

#func _on_cooking_scene_complete(_output: Variant) -> void:
	#cooking_scene.hide()

func _on_area_exited(_area: Area2D) -> void:
	reset_cooking()
	exit_cooking()
	sprite.material.set_shader_parameter("outline_color", Color.YELLOW)

func _on_area_entered(_area: Area2D) -> void:
	sprite.material.set_shader_parameter("outline_color", Color.GREEN)

func _to_string() -> String:
	return self.name
