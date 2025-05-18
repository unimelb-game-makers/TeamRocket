extends Node

var grid = []      # 2D Array for generation
const DIM_X = 7
const DIM_Y = 7

var roomdata = []

var starting_room = Vector2(2,2)
var current_room: Vector2
var current_selected

var curr_rooms = 0
var num_rooms = 20

var generation_queue = []

var max_neighbors = 2

var just_teleported1 = false
var just_teleported2 = false

@onready var navigation_region_2d: NavigationRegion2D = $NavigationRegion2D

const straight: PackedScene = preload("res://scenes/map/templates/straight.tscn")
const deadend: PackedScene = preload("res://scenes/map/templates/dead_end.tscn")
const bend: Array[PackedScene] = [
	preload("res://scenes/map/templates/turn.tscn"),
	preload("res://scenes/map/templates/turn2.tscn")
]
const threeway: Array[PackedScene] = [
	preload("res://scenes/map/templates/threeway.tscn"), 
	preload("res://scenes/map/templates/threeway2.tscn")
]
const full: PackedScene = preload("res://scenes/map/templates/fullroom.tscn")
const fulls: Array[PackedScene] = [
	#preload("res://scenes/map/templates/fullroom.tscn"),
	preload("res://scenes/map/templates/fullroom2.tscn")
]

const PLAYER = preload("res://scenes/player/Player.tscn")
var currplayer
var currcam

func _ready() -> void:
	for i in DIM_X:
		grid.append([])
		roomdata.append([])
		for j in DIM_Y:
			grid[i].append(0)
			roomdata[i].append(null)
	
	start_gen() # only grid explored here
	
	print(curr_rooms)
	var count = 0
	for i in range(DIM_Y):
		var row = ""
		for j in range(DIM_X):
			if grid[j][i]:
				row += "■ "
				count += 1
			else:
				row += "□ "
		print(row)
	
	# Initialize starting room and put player in it
	initialize_room(starting_room,)
	

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
			# If more than max_neighbors, exit
			if get_num_neighbors(grid, neighbor) > max_neighbors:
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

const directions = [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]

func check_bounds(pos: Vector2):
	if pos.x >= 0 and pos.x < DIM_X and pos.y >= 0 and pos.y < DIM_Y:
		return true

func get_neighbors(current_pos: Vector2) -> Array:
	var neighbors = []
	for d in directions:
		var pos: Vector2 = current_pos + d
		if check_bounds(pos):
			neighbors.append(pos)
	neighbors.shuffle()
	return neighbors

func get_num_neighbors(grid, current_pos: Vector2) -> int:
	var num = 0
	for d in directions:
		var neighbor: Vector2 = current_pos + d
		if check_bounds(neighbor) and grid[neighbor.x][neighbor.y] == 1:
			num += 1
	return num

# Room gen

func get_neighbors_array(grid, current_pos: Vector2) -> Array:
	var arr = []
	for d in directions:
		var neighbor = current_pos + d
		# Door
		if check_bounds(neighbor) and grid[neighbor.x][neighbor.y] == 1:
			arr.append("B")
		# Empty
		else:
			arr.append("A")
	return arr

func initialize_room(coords: Vector2, outgoing_direction: Vector2=Vector2.ZERO):
	var room = grid[coords.x][coords.y]
	var num_neighbors = get_num_neighbors(grid, coords)
	var neighbors_array = get_neighbors_array(grid, coords)
	
	var selected_room
	var curr_room_data = roomdata[coords.x][coords.y]
	
	if curr_room_data == null:
		var newroomdata = RoomData.new()
		
		match num_neighbors:
			1:
				newroomdata.roomscene = deadend
			2:
				if neighbors_array == ["A", "B", "A", "B"] or neighbors_array == ["B", "A", "B", "A"]:
					newroomdata.roomscene = straight
				else:
					newroomdata.roomscene = bend.pick_random()
			3:
				newroomdata.roomscene = threeway.pick_random()
			4:
				newroomdata.roomscene = fulls.pick_random()
		
		curr_room_data = newroomdata
		print("CREATED NEW ROOM DATA")
	
	selected_room = curr_room_data.roomscene.instantiate()
	
	for i in selected_room.spawnNodes:
		i.reparent($EnemyHandler/SpawnAreas)
	
	# Rotate room to match selected_room.sockets with neighbors_array
	var sockets: Array[String] = selected_room.sockets
	var doors = selected_room.doors
	var total_rotations = 0
	print("Fresh Sockets: " + str(sockets))
	while sockets != neighbors_array:
		var temp = sockets.pop_front()
		sockets.append(temp)
		
		var temp2 = doors.pop_front()
		doors.append(temp2)

		selected_room.rotate(-PI/2)
		total_rotations += -PI/2
	
	selected_room.doors = doors
	selected_room.sockets = sockets
	
	print("Aligned Sockets: " + str(sockets))
	print("Neighbors array: " + str(neighbors_array))
	
	#print("Assigning directions to doors: " + str(d))
	selected_room.connect_doors(directions)
	
	# Connect the door signal to the direction
	for i in range(len(selected_room.doors)):
		if selected_room.doors[i] == null:
			continue
		selected_room.doors[i].go_to_room.connect(Callable(self, "go_to_room"))
		selected_room.doors[i].player_exit.connect(Callable(self, "player_exit"))
	
	current_room = Vector2(coords.x, coords.y)
	current_selected = selected_room
	print("Current position" + str(coords))
	
	navigation_region_2d.call_deferred("add_child", selected_room)
	
	if selected_room.has_poi_markers():
		print("HAS POI MARKERS")
		if curr_room_data.poi_path == "":
			if randi_range(0, 3) > 3:
				curr_room_data.poi_path = "res://assets/map/POI/medium park background.png"
				curr_room_data.poi_size = "med"
			else:
				curr_room_data.poi_path = "res://assets/map/POI/large park background.png"
				curr_room_data.poi_size = "large"
		
		var poi_sprite: Sprite2D = Sprite2D.new()
		print("POI PATH: " + curr_room_data.poi_path)
		poi_sprite.texture = load(curr_room_data.poi_path)
		if curr_room_data.poi_size == "med":
			poi_sprite.global_position = selected_room.mediumSpawn.global_position
		elif curr_room_data.poi_size == "large":
			poi_sprite.global_position = selected_room.largeSpawn.global_position
		navigation_region_2d.call_deferred("add_child", poi_sprite)

	
	# Spawn player and camera
	var s: Player = PLAYER.instantiate()
	call_deferred("add_child", s)
	s.channel_complete.connect($GameHandler.switch_to_kitchen)
	s.global_position = selected_room.spawn.global_position
	currplayer = s
	
	#Spawn player at incoming door
	var incoming_direction = Vector2.ZERO - outgoing_direction
	if incoming_direction != Vector2.ZERO:
		assert(incoming_direction.is_normalized())
		var door_index = directions.find(incoming_direction)
		currplayer.global_position = selected_room.get_door_by_direction(incoming_direction).global_position
	
	var newcam = Camera2D.new()
	#newcam.make_current()
	currplayer.call_deferred("add_child", newcam)
	newcam.call_deferred("set_global_position", currplayer.global_position)
	newcam.zoom = Vector2(0.3,0.3)
	currcam = newcam

func go_to_room(direction: Vector2):
	if just_teleported1 == false and just_teleported2 == false:
		just_teleported1 = true
	else:
		return
	current_selected.queue_free()
	currplayer.queue_free()
	currcam.queue_free()
	initialize_room(Vector2(current_room.x + direction.x, current_room.y + direction.y), direction)
	
	print("Entered a door going into: " + str(direction))
	print("------------------")

func player_exit():
	if just_teleported1 == true and just_teleported2 == false:
		just_teleported2 = true
		return
	if just_teleported1 == true and just_teleported2 == true:
		just_teleported1 = false
		just_teleported2 = false
