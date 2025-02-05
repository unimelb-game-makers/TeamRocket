extends Control

"""
Minigame for frying ingredients.
1. Show frying pan sprite
2. Show ingredient in frying pan
3. Ingredient will randomly move around
4. Player will use "Movement" (WASD) to try to keep ingredient in middle of pan
5. Player will use "Dodge" (Space) to flip ingredient
6. Ingredients have 2 sides (for simplicity's sake)
"""

signal complete(output)

@onready var frying_pan: Sprite2D = $FryingPan
@onready var ingr: Sprite2D = $FryingPan/Ingredient
@onready var warning: Label = $FryingPan/Ingredient/Label
@onready var progress_debug: Label = $ProgressDebug

# Frying pan size
var pan_size_squared := 1600

# How long to fry for
var progress: Array = [0, 0]
var side: int = 0
@export var target_progress := 5.0

# A brief cooldown for the warning "!" flash
var warning_timer: float

# A cooldown for the ingredient's random movement
var sizzle_timer: float

# Fake velocity for moving ingredient
var velocity: Vector2

# Target to fry and amount fried so far
var fried = 0
@export var target = 2

var playing = false


func start() -> void:
	ingr.texture # = ingredient item texture here
	playing = true


func _process(delta: float) -> void:
	warning_timer -= delta
	sizzle_timer -= delta
	if (playing):
		# Note on using progess[side - 1]
		# This actually always works; if side == 0 -> progress[-1] -> progress[1]
		# if side == 1 -> progress[0]
		progress[side - 1] += delta * calculate_area()
		ingr.self_modulate.v = (target_progress - progress[side] * 0.75) / (target_progress)
		if progress[0] >= target_progress and progress[1] >= target_progress:
			print("Fried successfully!")
			fried += 1
			if fried >= target:
				finish()
				return
			progress.clear()
			progress.append(0)
			progress.append(0)
		if progress[side - 1] >= target_progress:
			if warning_timer <= 0:
				warning_timer = 0.5
				warning.visible = !warning.visible
	progress_debug.text = "%.2f, %.2f" % [progress[0], progress[1]]


func _physics_process(delta: float) -> void:
	if playing:
		var dir = Input.get_vector("left", "right", "up", "down")
		if dir:
			velocity += dir.normalized()
		else:
			velocity.move_toward(Vector2.ZERO, delta)
		if sizzle_timer <= 0:
			sizzle_timer = randf_range(1, 4)
			velocity += Vector2(randf_range(0, 5), randf_range(0, 5))
		move_ingredient(delta)

 
func move_ingredient(delta: float) -> void:
	ingr.position += velocity * delta
	ingr.position.limit_length(40)
	#ingr.position = ingr.position.clamp(Vector2(-pan_size.x, -pan_size.y), Vector2(pan_size.x, pan_size.y))


func calculate_area() -> float:
	var d = ingr.position.length_squared()
	if d < pan_size_squared / 4.0:
		return 1
	if d < pan_size_squared / 2.0:
		return 0.75
	if d < 3 * pan_size_squared / 4.0:
		return 0.25
	return 0.1


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("roll"):
		side = (side + 1) % 2
		warning.hide()
		warning_timer = 0


func finish() -> void:
	playing = false
	print("Frying Finished!")
	complete.emit()
