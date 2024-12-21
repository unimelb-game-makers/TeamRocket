extends Control

signal complete(output)

var playing = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func start() -> void:
	finish()
	playing = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func finish() -> void:
	print("Cooking Finished!")
	complete.emit()
