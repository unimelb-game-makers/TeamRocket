@tool
extends Line2D

@onready var oven_tracing_line = $"../OvenTracingLine"

@export var line_name: String # For saving purposes, ensure unique name or it will overwrite previous line

@export var reset = false:
	set(value):
		if value == true:
			self.clear_points()
		
@export var save = false:
	set(value):
		if value == true:
			# Create a new instance of the custom resource
			var new_resource = OvenLine.save_line(oven_tracing_line)
			
			
			# Define the file path where it will be saved
			var save_path = "res://scenes/cooking/workbenches/oven/oven_lines/oven_line_" + line_name + ".tres"
			

			# Save the resource to the file system
			var error = ResourceSaver.save(new_resource, save_path)
			
			# Check if the save was successful
			if error == OK:
				print("Resource saved successfully at ", save_path)
			else:
				print("Failed to save the resource")

@export_range(1, 100.0, 1) var perfect_line_width: float = 10: # Line width of the perfect line
	set(new_width):
		if oven_tracing_line != null:
			perfect_line_width = new_width
			oven_tracing_line.perfect_line_width = perfect_line_width
		
@export_range(1.1, 10.0, 0.1) var good_line_factor: float = 2: # Factor of size larger for good line from perfect line
	set(new_factor):
		if oven_tracing_line != null:
			good_line_factor = new_factor
			oven_tracing_line.good_line_factor = good_line_factor
		
@export_range(1.1, 10.0, 0.1) var passable_line_factor: float = 2: # Factor of size larger for perfect line from good line
	set(new_factor):
		if oven_tracing_line != null:
			passable_line_factor = new_factor
			oven_tracing_line.passable_line_factor = passable_line_factor

func _process(delta: float) -> void:
	oven_tracing_line.position = self.position
	oven_tracing_line.line_points = self.points
	
	self.width = oven_tracing_line.passable_line.width
