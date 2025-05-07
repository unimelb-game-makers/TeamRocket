@tool
class_name OvenTracingLine
extends Node2D

@onready var perfect_line: Line2D = $PerfectLine
@onready var good_line: Line2D = $GoodLine
@onready var passable_line: Line2D = $PassableLine
@onready var start: Area2D = $Start
@onready var end: Area2D = $End
@onready var start_shape: CollisionShape2D = $Start/CollisionShape2D
@onready var end_shape: CollisionShape2D = $End/CollisionShape2D

@export var line_points: PackedVector2Array:
	set(new_points):
		line_points = new_points
		if perfect_line != null:
			perfect_line.points = line_points
			good_line.points = line_points
			passable_line.points = line_points
			_update_start_and_end()
			
@export_range(1, 100.0, 1) var perfect_line_width: float = 10: # Line width of the perfect line
	set(new_width):
		if perfect_line != null:
			perfect_line_width = new_width
			perfect_line.width = perfect_line_width
			good_line.width = perfect_line.width * good_line_factor
			passable_line.width = good_line.width * passable_line_factor
			_update_start_and_end()
		
@export_range(1.1, 10.0, 0.1) var good_line_factor: float = 2: # Factor of size larger for good line from perfect line
	set(new_factor):
		if perfect_line != null:
			good_line_factor = new_factor
			good_line.width = perfect_line.width * good_line_factor
			passable_line.width = good_line.width * passable_line_factor
		
@export_range(1.1, 10.0, 0.1) var passable_line_factor: float = 2: # Factor of size larger for perfect line from good line
	set(new_factor):
		if perfect_line != null:
			passable_line_factor = new_factor
			passable_line.width = good_line.width * passable_line_factor

var is_playing: bool = true
var accuracy_table: Array = [0, 0, 0, 0]

enum ACCURACY_SCORES {
	PERFECT = 0,
	GOOD = 1,
	PASSABLE = 2,
	FAIL = 3
}

signal game_finish(accuracy: float) # End point reached, or leave line completely

func _ready() -> void:
	# Setup the lines width and points
	perfect_line.width = perfect_line_width
	good_line.width = perfect_line.width * good_line_factor
	passable_line.width = good_line.width * passable_line_factor
	perfect_line.points = line_points
	good_line.points = line_points
	passable_line.points = line_points
	
	_update_start_and_end()

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if is_playing:
			var mouse_pos = get_global_mouse_position()
			if is_mouse_on_line(perfect_line, mouse_pos):
				accuracy_table[ACCURACY_SCORES.PERFECT] += 1
				
			if is_mouse_on_line(good_line, mouse_pos):
				accuracy_table[ACCURACY_SCORES.GOOD] += 1
				
			if is_mouse_on_line(passable_line, mouse_pos):
				accuracy_table[ACCURACY_SCORES.PASSABLE] += 1
			else:
				accuracy_table[ACCURACY_SCORES.FAIL] += 1
				is_playing = false
				_end_minigame()
			
func _end_minigame() -> void:
	var accuracy = _process_accuracy_table()
	emit_signal("game_finish", accuracy)

func is_mouse_on_line(line: Line2D, mouse_pos: Vector2) -> bool:
	var points = line.points
	for i in range(points.size() - 1):
		var a = line.to_global(points[i])
		var b = line.to_global(points[i + 1])
		var dist = distance_to_segment(mouse_pos, a, b)
		if dist <= line.width/2:
			return true
	return false

func distance_to_segment(p: Vector2, a: Vector2, b: Vector2) -> float:
	# Vector calculation stuff, honestly got of GPT, forgot my vector knowledge...
	var ap = p - a
	var ab = b - a
	var ab_len_squared = ab.length_squared()
	if ab_len_squared == 0.0:
		return ap.length()
	var t = clamp(ap.dot(ab) / ab_len_squared, 0.0, 1.0)
	var closest_point = a + ab * t
	return p.distance_to(closest_point)

func get_starting_point() -> Vector2:
	if perfect_line.points.is_empty():
		return Vector2(0,0)
	return perfect_line.to_global(perfect_line.get_point_position(0))

func _get_ending_point() -> Vector2:
	if perfect_line.points.is_empty():
		return Vector2(0,0)
	return perfect_line.to_global(perfect_line.get_point_position(perfect_line.get_point_count() - 1))

func _update_start_and_end() -> void: 
	start.position = get_starting_point()
	end.position = _get_ending_point()
	
	var original_diameter_start = start_shape.shape.radius * 2.0
	
	if original_diameter_start > 0:
		var scale_factor = perfect_line.width / original_diameter_start
		start.scale = Vector2(scale_factor, scale_factor)
		
	var original_diameter_end = end_shape.shape.radius * 2.0
	
	if original_diameter_end > 0:
		var scale_factor = perfect_line.width / original_diameter_end
		end.scale = Vector2(scale_factor, scale_factor)

func _process_accuracy_table() -> float:
	var total_data_points = 0
	
	for points in accuracy_table:
		total_data_points += points
	# If any FAIL, it is a fail
	if accuracy_table[ACCURACY_SCORES.FAIL] > 0:
		return 0
	# If PERFECT > 95%
	elif accuracy_table[ACCURACY_SCORES.PERFECT] > total_data_points * 0.95:
		return 100
	# If PERFECT + GOOD > PASSABLE, it is GOOD
	elif accuracy_table[ACCURACY_SCORES.PERFECT] + accuracy_table[ACCURACY_SCORES.GOOD] > total_data_points * 0.50:
		return 60
	# Else passable
	else:
		return 40
	
func initialize_data(oven_line: OvenLine) -> void:
	line_points = oven_line.line_points
	perfect_line_width = oven_line.perfect_line_width
	good_line_factor = oven_line.good_line_factor
	passable_line_factor = oven_line.passable_line_factor
	
	_update_start_and_end()

func _on_end_mouse_entered() -> void:
	is_playing = false
	_end_minigame()
