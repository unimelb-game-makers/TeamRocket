extends Node
class_name MapGenerator

enum RoomTypeEnum {
	NONE,
	DEADEND,
	STRAIGHT,
	BEND,
	THREEWAY,
	FULL
}

@export_group("Debug")
@export var is_debug: bool = false
@export var debug_map_room_scene: PackedScene
@export_group("Unique PoI")
@export var convenient_alcove_interior: PackedScene
@export var the_kingdom_interior: PackedScene


@onready var navigation_region_2d: NavigationRegion2D = $NavigationRegion2D
@onready var game_handler: GameHandler = $GameHandler
@onready var player: Player = $Player
@onready var enemy_handler: EnemyHandler = $EnemyHandler
@onready var interactable_handler: InteractableHandler = $InteractableHandler

var grid: Array[Array] = [] # 2D Array for generation
const DIM_X = 7
const DIM_Y = 7
const DIRECTION_UNIT: Array[Vector2] = [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]
const MAX_NEIGHBORS = 2

var all_room_data = []
var all_unique_room_data = []

var just_init = true
var starting_room = Vector2(2, 2)
var current_room_coord: Vector2
var current_selected_room: ProceduralRoom

var curr_rooms = 0
var num_rooms = 20

var generation_queue = []

var just_teleported1 = false
var just_teleported2 = false

# For unique PoI interior
var is_in_unique_room = false
var current_unique_room_id: PlaceablePOI.UniquePoiEnum = PlaceablePOI.UniquePoiEnum.NONE
var last_room_data: RoomData
var last_room_coord: Vector2
var last_room_player_pos: Vector2

var deadend_N: Array[PackedScene] = [
	preload("res://scenes/map/templates/DeadEndN.tscn")
]
var deadend_E: Array[PackedScene] = [
	preload("res://scenes/map/templates/DeadEndE.tscn")
]
var deadend_S: Array[PackedScene] = [
	preload("res://scenes/map/templates/DeadEndS.tscn"),
	preload("res://scenes/map/map_tile_variations/DeadEndCityS.tscn"),
	preload("res://scenes/map/map_tile_variations/DeadEndParkS.tscn")
]
var deadend_W: Array[PackedScene] = [
	preload("res://scenes/map/templates/DeadEndW.tscn")
]

var straight_NS: Array[PackedScene] = [
	preload("res://scenes/map/templates/StraightNS.tscn")
]
var straight_EW: Array[PackedScene] = [
	preload("res://scenes/map/templates/StraightEW.tscn")
]

var bend_NE: Array[PackedScene] = [
	preload("res://scenes/map/templates/TurnNE.tscn"),
]
var bend_NW: Array[PackedScene] = [
	preload("res://scenes/map/templates/TurnNW.tscn"),
]
var bend_SE: Array[PackedScene] = [
	preload("res://scenes/map/templates/TurnSE.tscn"),
]
var bend_SW: Array[PackedScene] = [
	preload("res://scenes/map/templates/TurnSW.tscn"),
]

# Means "Threeway no North direction"
var threeway_noN: Array[PackedScene] = [
	preload("res://scenes/map/templates/ThreewayNoN.tscn"),
	preload("res://scenes/map/map_tile_variations/ThreewayCityNoN.tscn"),
	preload("res://scenes/map/map_tile_variations/ThreewayCityGreenNoN.tscn")
]
var threeway_noE: Array[PackedScene] = [
	preload("res://scenes/map/templates/ThreewayNoE.tscn"),
	preload("res://scenes/map/map_tile_variations/ThreewayCityNoE.tscn"),
	preload("res://scenes/map/map_tile_variations/ThreewayCityGreenNoE.tscn")
]
var threeway_noS: Array[PackedScene] = [
	preload("res://scenes/map/templates/ThreewayNoS.tscn"),
	preload("res://scenes/map/map_tile_variations/ThreewayCityGreenNoS.tscn")
]
var threeway_noW: Array[PackedScene] = [
	preload("res://scenes/map/templates/ThreewayNoW.tscn"),
	preload("res://scenes/map/map_tile_variations/ThreewayCityNoW.tscn"),
	preload("res://scenes/map/map_tile_variations/ThreewayCityGreenNoW.tscn")
]
var fulls: Array[PackedScene] = [
	preload("res://scenes/map/templates/Fullroom.tscn"),
	preload("res://scenes/map/map_tile_variations/FullroomCityIntersection.tscn"),
	preload("res://scenes/map/map_tile_variations/FullroomGreenCity2.tscn"),
	preload("res://scenes/map/map_tile_variations/FullroomGreenCity.tscn"),

]

var curr_player: Player

func _ready() -> void:
	Globals.map_generator = self
	clear_unused_node()
	for i in range(PlaceablePOI.UniquePoiEnum.size()):
		all_unique_room_data.append(null)

	for i in DIM_X:
		grid.append([])
		all_room_data.append([])
		for j in DIM_Y:
			grid[i].append(0)
			all_room_data[i].append(null)

	if not is_debug:
		start_gen() # only grid explored here
	else:
		grid[starting_room.x][starting_room.y] = 1

	# Debug stuff
	var _count = 0
	for i in range(DIM_Y):
		var row = ""
		for j in range(DIM_X):
			if grid[j][i]:
				if i == 2 and j == 2:
					row += "◩ "
				else:
					row += "■ "
				_count += 1
			else:
				row += "□ "
		print(row)


	# Initialize starting room and put player in it
	initialize_room(starting_room)
	just_init = false

	await get_tree().process_frame
	await get_tree().process_frame

	Globals.player_ui.create_minimap(grid, current_room_coord)

func start_gen():
	grid[starting_room.x][starting_room.y] = 1
	generation_queue.append(starting_room)

	while not generation_queue.is_empty() and curr_rooms < num_rooms:
		var curr
		if randi_range(0, 3) == 0:
			curr = generation_queue.pop_front()
		else:
			curr = generation_queue.pop_back()
		for neighbor in get_neighbors(curr):
			# If room already occupied, exit
			if grid[neighbor.x][neighbor.y] == 1:
				continue
			# If more than MAX_NEIGHBORS, exit
			if get_num_neighbors(grid, neighbor) > MAX_NEIGHBORS:
				#if randi_range(0, 1):
					#continue
				continue
			# Random
			if randi_range(0, 1):
				if num_rooms < num_rooms - 5:
					continue
			if randi_range(0, 4):
				generation_queue.append(starting_room)

			# Create new room
			grid[neighbor.x][neighbor.y] = 1
			curr_rooms += 1
			generation_queue.append(neighbor)


func check_bounds(pos: Vector2):
	if pos.x >= 0 and pos.x < DIM_X and pos.y >= 0 and pos.y < DIM_Y:
		return true

func get_neighbors(current_pos: Vector2) -> Array:
	var neighbors = []
	for d in DIRECTION_UNIT:
		var pos: Vector2 = current_pos + d
		if check_bounds(pos):
			neighbors.append(pos)
	neighbors.shuffle()
	return neighbors

func get_num_neighbors(_grid, current_pos: Vector2) -> int:
	var num = 0
	for d in DIRECTION_UNIT:
		var neighbor: Vector2 = current_pos + d
		if check_bounds(neighbor) and _grid[neighbor.x][neighbor.y] == 1:
			num += 1
	return num

# Room gen

func get_neighbors_array(_grid, current_pos: Vector2) -> Array[bool]:
	var arr: Array[bool] = []
	for d in DIRECTION_UNIT:
		var neighbor = current_pos + d
		# Door
		if check_bounds(neighbor) and _grid[neighbor.x][neighbor.y] == 1:
			arr.append(true)
		# Empty
		else:
			arr.append(false)
	return arr

func initialize_room(coord: Vector2, outgoing_direction: Vector2 = Vector2.ZERO):
	var num_neighbors = get_num_neighbors(grid, coord)
	var neighbors_array = get_neighbors_array(grid, coord)
	var selected_room: ProceduralRoom
	var curr_room_data = all_room_data[coord.x][coord.y]

	# New room, instantiate new room data
	if curr_room_data == null:
		var new_room_data = RoomData.new()
		new_room_data.coord = coord
		var room_type: RoomTypeEnum = RoomTypeEnum.NONE
		match num_neighbors:
			1:
				room_type = RoomTypeEnum.DEADEND
			2:
				if neighbors_array == [true, false, true, false] or neighbors_array == [false, true, false, true]:
					room_type = RoomTypeEnum.STRAIGHT
				else:
					room_type = RoomTypeEnum.BEND
			3:
				room_type = RoomTypeEnum.THREEWAY
			4:
				room_type = RoomTypeEnum.FULL


		# Now choose the right room scene to use
		match room_type:
			RoomTypeEnum.DEADEND:
				# If only 1 neighbor at the North, use the deadend_N, which mean
				# deadend map room with door at North. And so on.
				if check_neighbor_arr_at_dir(neighbors_array, DIRECTION_UNIT[0]):
					new_room_data.room_scene = deadend_N.pick_random()
				elif check_neighbor_arr_at_dir(neighbors_array, DIRECTION_UNIT[1]):
					new_room_data.room_scene = deadend_E.pick_random()
				elif check_neighbor_arr_at_dir(neighbors_array, DIRECTION_UNIT[2]):
					new_room_data.room_scene = deadend_S.pick_random()
				elif check_neighbor_arr_at_dir(neighbors_array, DIRECTION_UNIT[3]):
					new_room_data.room_scene = deadend_W.pick_random()
			RoomTypeEnum.STRAIGHT:
				if check_neighbor_arr_at_dir(neighbors_array, DIRECTION_UNIT[0]) and \
					check_neighbor_arr_at_dir(neighbors_array, DIRECTION_UNIT[2]):
					new_room_data.room_scene = straight_NS.pick_random()
				elif check_neighbor_arr_at_dir(neighbors_array, DIRECTION_UNIT[1]) and \
					check_neighbor_arr_at_dir(neighbors_array, DIRECTION_UNIT[3]):
					new_room_data.room_scene = straight_EW.pick_random()
			RoomTypeEnum.BEND:
				if check_neighbor_arr_at_dir(neighbors_array, DIRECTION_UNIT[0]) and \
					check_neighbor_arr_at_dir(neighbors_array, DIRECTION_UNIT[1]):
					new_room_data.room_scene = bend_NE.pick_random()
				elif check_neighbor_arr_at_dir(neighbors_array, DIRECTION_UNIT[1]) and \
					check_neighbor_arr_at_dir(neighbors_array, DIRECTION_UNIT[2]):
					new_room_data.room_scene = bend_SE.pick_random()
				elif check_neighbor_arr_at_dir(neighbors_array, DIRECTION_UNIT[2]) and \
					check_neighbor_arr_at_dir(neighbors_array, DIRECTION_UNIT[3]):
					new_room_data.room_scene = bend_SW.pick_random()
				elif check_neighbor_arr_at_dir(neighbors_array, DIRECTION_UNIT[0]) and \
					check_neighbor_arr_at_dir(neighbors_array, DIRECTION_UNIT[3]):
					new_room_data.room_scene = bend_NW.pick_random()
			RoomTypeEnum.THREEWAY:
				if not check_neighbor_arr_at_dir(neighbors_array, DIRECTION_UNIT[0]):
					new_room_data.room_scene = threeway_noN.pick_random()
				elif not check_neighbor_arr_at_dir(neighbors_array, DIRECTION_UNIT[1]):
					new_room_data.room_scene = threeway_noE.pick_random()
				elif not check_neighbor_arr_at_dir(neighbors_array, DIRECTION_UNIT[2]):
					new_room_data.room_scene = threeway_noS.pick_random()
				elif not check_neighbor_arr_at_dir(neighbors_array, DIRECTION_UNIT[3]):
					new_room_data.room_scene = threeway_noW.pick_random()
			RoomTypeEnum.FULL:
				if just_init:
					new_room_data.room_scene = fulls[0]
				else:
					new_room_data.room_scene = fulls.pick_random()

		if is_debug:
			new_room_data.room_scene = debug_map_room_scene

		new_room_data.is_new = true
		curr_room_data = new_room_data
		all_room_data[coord.x][coord.y] = new_room_data
	else:
		curr_room_data.is_new = false


	selected_room = curr_room_data.room_scene.instantiate()
	selected_room.coord = coord

	selected_room.connect_doors(DIRECTION_UNIT)

	# Connect the door signal to the direction
	for i in range(len(selected_room.doors)):
		if selected_room.doors[i] == null:
			continue
		selected_room.doors[i].go_to_room.connect(Callable(self, "go_to_room"))
		selected_room.doors[i].player_exit.connect(Callable(self, "player_exit"))

	current_room_coord = Vector2(coord.x, coord.y)
	current_selected_room = selected_room
	print("CURRENT POSITION " + str(coord))

	navigation_region_2d.add_child(selected_room)

	# Copy the selected_room's navigation region data into the CityGeneratedMap room
	if selected_room.navigation_region != null:
		navigation_region_2d.navigation_polygon = selected_room.navigation_region.navigation_polygon
		selected_room.navigation_region.queue_free()
	else:
		push_warning("This room {0} doesn't have NavigationRegion".format([selected_room.room_name]))

	spawn_stuff_post_room_init(curr_room_data, false, outgoing_direction)


func initialize_unique_poi_room(unique_poi_scene: PackedScene, unique_room_id: PlaceablePOI.UniquePoiEnum):
	var selected_room: ProceduralRoom
	var curr_room_data = all_unique_room_data[int(unique_room_id) - 1]

	if curr_room_data == null:
		var new_room_data = RoomData.new()
		new_room_data.is_unique_poi = true
		print("POPOPOPOPOPO ")
		new_room_data.room_scene = unique_poi_scene
		new_room_data.is_new = true
		curr_room_data = new_room_data
		all_unique_room_data[int(unique_room_id) - 1] = new_room_data
	else:
		curr_room_data.is_new = false

	selected_room = curr_room_data.room_scene.instantiate()
	current_selected_room = selected_room
	print("CURRENT UNIQUE POI ROOM: " + current_selected_room.room_name)

	navigation_region_2d.add_child(selected_room)

	# Copy the selected_room's navigation region data into the CityGeneratedMap room
	if selected_room.navigation_region != null:
		navigation_region_2d.navigation_polygon = selected_room.navigation_region.navigation_polygon
		selected_room.navigation_region.queue_free()
	else:
		push_warning("This room {0} doesn't have NavigationRegion".format([selected_room.room_name]))

	spawn_stuff_post_room_init(curr_room_data, true)


func spawn_stuff_post_room_init(curr_room_data: RoomData, is_unique_poi: bool = false,
	outgoing_direction: Vector2 = Vector2.ZERO):
	# Spawn player and camera
	player.camera.temporarily_disable_smooth_for_scene_change()
	player.global_position = current_selected_room.get_player_spawn_pos()
	curr_player = player
	print("POS 1", curr_player.global_position)

	# Spawn player at right position
	if is_unique_poi:
		# Player enter unique PoI
		curr_player.global_position = current_selected_room.player_spawn.global_position
	else:
		if outgoing_direction == Vector2.ZERO and not just_init:
			# Player just left unique PoI
			curr_player.global_position = last_room_player_pos
		else:
			var incoming_direction = Vector2.ZERO - outgoing_direction
			if incoming_direction != Vector2.ZERO:
				assert(incoming_direction.is_normalized())
				curr_player.global_position = current_selected_room.get_door_by_direction(incoming_direction).global_position

	print("POS", curr_player.global_position)

	# Spawn POI
	current_selected_room.spawn_poi()
	navigation_region_2d.bake_navigation_polygon()

	# Spawn loot in crate
	current_selected_room.generate_loot_for_container()

	# Reorganize entities
	for elem in current_selected_room.get_enemy_spawns():
		elem.reparent(enemy_handler.spawn_areas)

	for elem in current_selected_room.get_enemies():
		elem.reparent(enemy_handler)

	for elem in current_selected_room.get_interactables():
		elem.reparent(interactable_handler.interactable_holder)

	# Check for saved and load
	# TODO: Improve how we save/load interactables later, this doesn't scale well
	if not curr_room_data.is_new:
		for elem in interactable_handler.interactable_holder.get_children():
			# If node has this method, it mean it can be saved.
			# Therefore, we should delete all of them and re-instantiate from saved data.
			if elem.has_method("get_save_data"):
				elem.queue_free()
		# Now, re-instantiate them
		interactable_handler.spawn_interactables_from_save()

	# Spawn enemies
	enemy_handler.spawn_enemies()


func go_to_room(direction: Vector2):
	if just_teleported1 == false and just_teleported2 == false:
		just_teleported1 = true
	else:
		return
	var current_room_data = all_room_data[current_room_coord.x][current_room_coord.y] as RoomData

	# Save current room data
	current_room_data.save_room_data()
	enemy_handler.clear_room()
	interactable_handler.clear_room()
	current_selected_room.queue_free()

	await get_tree().process_frame
	await get_tree().process_frame

	initialize_room(Vector2(current_room_coord.x + direction.x, current_room_coord.y + direction.y), direction)

	print("Entered a door going into: " + str(direction))
	print("------------------")

	print("Current room ", current_room_coord)
	Globals.player_ui.create_minimap(grid, current_room_coord)


func enter_unique_poi_room(unique_poi_scene: PackedScene, unique_room_id: PlaceablePOI.UniquePoiEnum):
	var current_room_data = all_room_data[current_room_coord.x][current_room_coord.y] as RoomData
	is_in_unique_room = true
	current_unique_room_id = unique_room_id
	last_room_data = current_room_data
	last_room_coord = current_room_coord
	last_room_player_pos = curr_player.global_position
	current_room_data.save_room_data()
	enemy_handler.clear_room()
	interactable_handler.clear_room()
	current_selected_room.queue_free()

	await get_tree().process_frame
	await get_tree().process_frame

	initialize_unique_poi_room(unique_poi_scene, unique_room_id)

	print("Entered a unique POI room")
	print("------------------")
	Globals.player_ui.create_minimap(grid, current_room_coord)

func exit_unique_poi_room(unique_room_id: PlaceablePOI.UniquePoiEnum):
	var current_room_data = all_unique_room_data[int(unique_room_id) - 1] as RoomData
	is_in_unique_room = false
	current_room_data.save_room_data()
	enemy_handler.clear_room()
	interactable_handler.clear_room()
	current_selected_room.queue_free()

	await get_tree().process_frame
	await get_tree().process_frame

	initialize_room(Vector2(last_room_coord.x, last_room_coord.y), Vector2.ZERO)

	print("Current room ", current_room_coord)
	Globals.player_ui.create_minimap(grid, current_room_coord)


func player_exit():
	if just_teleported1 == true and just_teleported2 == false:
		just_teleported2 = true
		return
	if just_teleported1 == true and just_teleported2 == true:
		just_teleported1 = false
		just_teleported2 = false

func clear_unused_node():
	navigation_region_2d.get_node("Map").queue_free()

func get_current_room_data() -> RoomData:
	var current_room_data: RoomData = null
	if is_in_unique_room:
		current_room_data = all_unique_room_data[int(current_unique_room_id) - 1]
	else:
		current_room_data = all_room_data[current_room_coord.x][current_room_coord.y]
	return current_room_data


func check_room_socket_at_dir(sockets: Array[ProceduralRoom.RoomSocketEnum], dir: Vector2) -> ProceduralRoom.RoomSocketEnum:
	var dir_index = DIRECTION_UNIT.find(dir)
	return sockets[dir_index]

func check_neighbor_arr_at_dir(neighbors_array: Array[bool], dir: Vector2) -> bool:
	var dir_index = DIRECTION_UNIT.find(dir)
	return neighbors_array[dir_index]
