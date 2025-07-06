extends ColorRect
class_name MinimapSquare

@onready var path_top: Control = $PathTop
@onready var path_down: Control = $PathDown
@onready var path_left: Control = $PathLeft
@onready var path_right: Control = $PathRight

func init(map_grid: Array[Array], current_coord: Vector2, current_room: Vector2):
	if map_grid[current_coord.x][current_coord.y]:
		if current_coord == current_room:
			self_modulate = Color.GREEN
		else:
			self_modulate = Color.WHITE
	else:
		self_modulate = Color(0, 0, 0, 0)

	# Create pathing
	path_top.visible = false
	path_down.visible = false
	path_left.visible = false
	path_right.visible = false

	if not map_grid[current_coord.x][current_coord.y]:
		return

	var dim_x = map_grid.size()
	var dim_y = map_grid[0].size()

	if current_coord.y > 0 and map_grid[current_coord.x][current_coord.y - 1]:
		path_top.visible = true
	if current_coord.y < dim_y - 1 and map_grid[current_coord.x][current_coord.y + 1]:
		path_down.visible = true
	if current_coord.x > 0 and map_grid[current_coord.x - 1][current_coord.y]:
		path_left.visible = true
	if current_coord.x < dim_x - 1 and map_grid[current_coord.x + 1][current_coord.y]:
		path_right.visible = true
