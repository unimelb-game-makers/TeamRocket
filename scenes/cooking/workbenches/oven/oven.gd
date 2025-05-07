extends Node2D

@export var oven_tracing_line_data: OvenLine

@onready var oven_tracing_line: OvenTracingLine = $OvenTracingLine
@onready var player_cursor: Area2D = $Area2D

func _ready() -> void:
	oven_tracing_line.game_finish.connect(minigame_complete)
	# Setup the board and player
	oven_tracing_line.initialize_data(oven_tracing_line_data)
	player_cursor.position = oven_tracing_line.get_starting_point()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		print("Mouse Click/Unclick at: ", event.position)
	elif event is InputEventMouseMotion:
		player_cursor.position = player_cursor.position + event.screen_relative
	
func minigame_complete(accuracy: float) -> void:
	print("Game completed!")
	print("Accuracy: ", accuracy)
