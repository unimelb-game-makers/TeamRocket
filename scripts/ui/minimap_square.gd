extends ColorRect
class_name MinimapSquare

@onready var path_top: Control = $PathTop
@onready var path_down: Control = $PathDown
@onready var path_left: Control = $PathLeft
@onready var path_right: Control = $PathRight

func init_minimap(map_grid: Array[Array], coord: Vector2, room_coord: Vector2):
	if map_grid[coord.x][coord.y]:
		if coord == room_coord:
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

	if not map_grid[coord.x][coord.y]:
		return

	var dim_x = map_grid.size()
	var dim_y = map_grid[0].size()

	if coord.y > 0 and map_grid[coord.x][coord.y - 1]:
		path_top.visible = true
	if coord.y < dim_y - 1 and map_grid[coord.x][coord.y + 1]:
		path_down.visible = true
	if coord.x > 0 and map_grid[coord.x - 1][coord.y]:
		path_left.visible = true
	if coord.x < dim_x - 1 and map_grid[coord.x + 1][coord.y]:
		path_right.visible = true
