extends CookingActivity

"""
Minigame for frying ingredients.
1. Show frying pan sprite
2. Show ingredient in frying pan
3. Ingredient will randomly move around
4. Player will use "Movement" (WASD) to try to keep ingredient in middle of pan
5. Player will use "Dodge" (Space) to flip ingredient
6. Ingredients have 2 sides (for simplicity's sake)
"""

"""
Permanent note (remove this if the shader script is removed):
There is a shader script attached to "FryingPan", intended
to manage visual indicators for point ranges on the pan
Currently, this is unused, as we just use a texture2D instead
"""

@onready var frying_pan: Sprite2D = $FryingPan
@onready var ingr: Sprite2D = $FryingPan/Ingredient
@onready var warning: Label = $FryingPan/Ingredient/Label
@onready var progress_debug: Label = $ProgressDebug
#@onready var ingredient_handler: HBoxContainer = %IngredientHandler
@onready var ingr_sprite: Sprite2D = $FryingPan/Ingredient/Sprite
@onready var tip_text: Label = $TipText
@onready var fry_progress: TextureProgressBar = $FryProgress


## Radius of frying pan
@export var PAN_SIZE: float = 75
# We do this calculation just once and store it, since it
# will be used a lot
@onready var PAN_SIZE_SQUARED = PAN_SIZE * PAN_SIZE


# How long to fry for
var progress: Array = [0, 0]
var side: int = 0
## How long to fry each side for, in number of seconds
@export var target_progress := 5.0

# A brief cooldown for the warning "!" flash
var warning_timer: float

# A cooldown for the ingredient's random movement
var sizzle_timer: float

# Fake velocity for moving ingredient
var velocity: Vector2

# Target to fry and amount fried so far
var fried := 0
var target := 0

# This will go to false when flipping the pan
var cooking: bool = false

# This will go to false when the activity is finished
var playing: bool = false

func _ready() -> void:
	if input_ingredients.size() == 0 or input_ingredients == null:
		push_error("There needs to atleast be one input ingredient by default to run this minigame!")
		return
	
	if get_tree().current_scene == self or is_initialized: # Runs if it as current scene or was initialized by something else then added to tree 
		fry_progress.max_value = 2 * target_progress
		tip_text.self_modulate.a = 0
		#target = ingredient_handler.selected_ingredients.size() # HELP: Not sure why getting size this way
		target = input_ingredients.size()
		$FryingPan/Rings.scale *= PAN_SIZE / 55.0
		playing = true
		cooking = true
		drop_ingredient()
		print(PAN_SIZE, ", ", PAN_SIZE_SQUARED)

#func start(input_ingredients: Array[Ingredient], output_item: Item) -> void:
	##super(input_ingredients, output_item)
	#fry_progress.max_value = 2 * target_progress
	#tip_text.self_modulate.a = 0
	#target = ingredient_handler.selected_ingredients.size()
	#$FryingPan/Rings.scale *= PAN_SIZE / 55.0
	#playing = true
	#cooking = true
	#drop_ingredient()
	#print(PAN_SIZE, ", ", PAN_SIZE_SQUARED)

func _process(delta: float) -> void:
	warning_timer -= delta
	sizzle_timer -= delta
	if (playing):
		# Note on using progess[side - 1]
		# This actually always works; if side == 0 -> progress[-1] -> progress[1]
		# if side == 1 -> progress[0]
		if cooking:
			progress[side - 1] += delta * calculate_area(delta)
			fry_progress.value = clampf(progress[0], 0, target_progress) + clampf(progress[1], 0, target_progress)
		if progress[0] >= target_progress and progress[1] >= target_progress:
			print("Fried successfully!")
			fried += 1
			if fried >= target:
				minigame_complete()
				return
			progress.clear()
			progress.append(0)
			progress.append(0)
			drop_ingredient()
		if progress[side - 1] >= target_progress: # What does this branch mean?
			if warning_timer <= 0:
				warning_timer = 0.5
				warning.visible = !warning.visible
	progress_debug.text = "%.2f, %.2f | %.1f/%.1f" % [progress[0], progress[1], fry_progress.value, fry_progress.max_value]


func _physics_process(delta: float) -> void:
	if playing and cooking:
		var dir = Input.get_vector("left", "right", "up", "down")
		if dir:
			velocity += dir.normalized()
		else:
			velocity.move_toward(Vector2.ZERO, delta * PAN_SIZE)
		if sizzle_timer <= 0:
			# This moves the ingredient randomly
			sizzle_timer = randf_range(1, 4)
			velocity *= randf_range(0.5, 2)
			velocity += Vector2(randf_range(-15, 15), randf_range(-15, 15))
	move_ingredient(delta)

 
func move_ingredient(delta: float) -> void:
	ingr.position += velocity * delta
	if ingr.position.length_squared() >= PAN_SIZE_SQUARED:
		velocity *= 0.5
		ingr.position = ingr.position.limit_length(PAN_SIZE)


func calculate_area(delta) -> float:
	var d = ingr.position.length_squared()
	if d < PAN_SIZE_SQUARED / 36.0:
		tip_text.self_modulate.a = clampf(tip_text.self_modulate.a - delta * 4, 0, 1)
		$FryingPan/Rings.modulate.a = clampf($FryingPan/Rings.modulate.a - delta, 0, 1)
		return 1
	if d < PAN_SIZE_SQUARED / 9.0:
		tip_text.self_modulate.a = clampf(tip_text.self_modulate.a - delta * 4, 0, 1)
		$FryingPan/Rings.modulate.a = clampf($FryingPan/Rings.modulate.a - delta, 0, 1)
		return 0.5
	tip_text.self_modulate.a = clampf(tip_text.self_modulate.a + delta * 4, 0, 1)
	$FryingPan/Rings.modulate.a = clampf($FryingPan/Rings.modulate.a + delta, 0, 1)
	if d < 4 * PAN_SIZE_SQUARED / 9.0:
		return 0.25
	return 0.1


# Currently, this is only for flipping ingredient
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("roll") and cooking:
		cooking = false
		side = (side + 1) % 2
		warning.hide()
		warning_timer = 0
		ingr_sprite.self_modulate.v = (target_progress - progress[side] * 0.6) / (target_progress)
		$AnimationPlayer.play("flip")
		await $AnimationPlayer.animation_finished
		cooking = true


## Use this whenever the game starts a new ingredient
func drop_ingredient() -> void:
	cooking = false # Pause the cooking
	#ingr_sprite.texture = (ingredient_handler.selected_ingredients[fried]).texture
	ingr_sprite.texture = (input_ingredients[fried]).texture
	ingr.scale = Vector2(20.0, 20.0) / ingr_sprite.texture.get_size()
	ingr.position = Vector2.ZERO
	ingr_sprite.self_modulate.v = (target_progress - progress[side] * 0.6) / (target_progress)
	$AnimationPlayer.play("drop")
	await $AnimationPlayer.animation_finished
	cooking = true


func minigame_complete() -> void:
	playing = false
	print("Frying Finished!")
	finish(Item.Quality.GOOD)
