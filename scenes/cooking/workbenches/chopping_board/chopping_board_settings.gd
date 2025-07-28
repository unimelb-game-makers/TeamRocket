class_name ChoppingBoardSettings
extends Resource

"""
Resource that simply stores the data to modify the chopping board settings.
"""

@export var perfect_range = 10  ## The range (percentage) for the perfect region
@export var perfect_progress = 10  ## Progress for perfect chop
@export var okay_range = 40     ## The range (percentage) for the okay region
@export var okay_progress = 5     ## Progress for okay chop
@export var target = 50         ## Total chop progress required
@export var speed = 300         ## Speed of marker movement (pixels/sec)
