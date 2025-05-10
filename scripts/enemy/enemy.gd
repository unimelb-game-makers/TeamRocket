class_name Enemy
extends CharacterBody2D

@export var health: int:
	set(value):
		if health > value:
			damage()
		health = value
		if health <= 0:
			die()

@export var dropped_items: Array[Item]
@export var dropped_item_chances: Array[float]
## If this valye + player's sound loudness larger than distance to player, enemy can hear. 
## Should keep it low for most enemies.
@export var hearing_sensitivity: float = 10
@export var sounds: Dictionary[String, Array]

var item_floor_scene: PackedScene = preload("res://scenes/item/ItemOnFloor.tscn")
var attack_damage: int

func damage() -> void:
	# Override in subclass
	# Play any damaged effects/animations
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.8, 0.5, 0.5), 0.2)
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.2)

func die() -> void:
	# Override in subclass
	# Play death effects then die
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
	await tween.finished
	drop_item()
	Globals.enemy_handler.remove_enemy_from_list(self)
	queue_free()
	
func drop_item():
	var item = randomize_dropped_item()
	if item:
		var dropped_item = item_floor_scene.instantiate()
		dropped_item.item = item
		get_tree().get_first_node_in_group("ItemHandler").add_child(dropped_item)
		dropped_item.set_item()
		dropped_item.position = global_position
	
func randomize_dropped_item():
	var random = randf_range(0, 1)
	print(random)
	# Calculate total weights distribution
	var total_weights = []
	for i in range(dropped_item_chances.size()):
		total_weights.append(0.0)
		for weight in dropped_item_chances.slice(0, i + 1):
			total_weights[i] += weight
	print(total_weights)
	# Determine which drop is chosen
	for i in range(total_weights.size()):
		if (total_weights[0] > random):
			return dropped_items[i]
	
	return null

func play_sound(sound_name: String):
	var sound_library: Array = sounds[sound_name]
	var sound_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	var random = randi_range(0, len(sound_library)-1)
	sound_player.bus = "Effects"
	add_child(sound_player)
	sound_player.stream = sound_library[random]
	sound_player.play(0.0)
	await get_tree().create_timer(sound_library[random].get_length()).timeout
	sound_player.queue_free()
	
func alerted(_sound_position: Vector2):
	return
