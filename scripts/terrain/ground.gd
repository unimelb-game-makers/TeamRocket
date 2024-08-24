extends TileMapLayer

@onready var walls: TileMapLayer = %Walls

# Script to remove navigation tile data from ground script so enemy navigation agents do not path into walls
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	if (coords in walls.get_used_cells_by_id(-1)):
		return true
	return false
	
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	tile_data.set_navigation_polygon(0, null)
