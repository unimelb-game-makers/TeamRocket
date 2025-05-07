class_name OvenLine
extends Resource

@export var perfect_line_width: float
@export var good_line_factor: float
@export var passable_line_factor: float
@export var line_points: PackedVector2Array

static func save_line(line: OvenTracingLine) -> OvenLine:
	var oven_line: OvenLine = OvenLine.new()
	
	oven_line.perfect_line_width = line.perfect_line_width
	oven_line.good_line_factor = line.good_line_factor
	oven_line.passable_line_factor = line.passable_line_factor
	oven_line.line_points = line.line_points
	
	return oven_line
