@tool
class_name OvenLine
extends MinigameSettings

"""
Contains the data for a mingame of the oven, includes:
	The size and shape of the line
	The total time allocated to complete the map
"""

@export_category("Time Allocated")
@export_range(1, 300, 1) var time_allocated: int = 20 ## Time allocated in seconds

@export_category("Line Data")
@export var perfect_line_width: float ## The pixel size for the perfect line
@export var good_line_factor: float ## 
@export var passable_line_factor: float
@export var line_points: PackedVector2Array

static func save_line(line: OvenTracingLine) -> OvenLine:
	var oven_line: OvenLine = OvenLine.new()
	
	oven_line.perfect_line_width = line.perfect_line_width
	oven_line.good_line_factor = line.good_line_factor
	oven_line.passable_line_factor = line.passable_line_factor
	oven_line.line_points = line.line_points
	
	return oven_line
