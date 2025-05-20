extends Area2D

@onready var recipe_ui = $UI
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	recipe_ui.visible = false
	sprite.material.set_shader_parameter("outline_color", Color.YELLOW)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and (recipe_ui.visible):
		exit_recipe_book_viewing()
		get_viewport().set_input_as_handled()

func interact():
	if recipe_ui.visible:
		Globals.player.set_player_movement(true)
	else:
		Globals.player.set_player_movement(false)
	recipe_ui.visible = not recipe_ui.visible

func exit_recipe_book_viewing():
	recipe_ui.visible = false
	Globals.player.set_player_movement(true)


func _on_area_exited(_area: Area2D) -> void:
	recipe_ui.hide()
	sprite.material.set_shader_parameter("outline_color", Color.YELLOW)

func _on_area_entered(_area: Area2D) -> void:
	sprite.material.set_shader_parameter("outline_color", Color.GREEN)
