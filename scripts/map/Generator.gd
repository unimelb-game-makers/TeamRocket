extends Node

var grid = []      # 2D Array for generation
var structure = [] # 2D Array holding the room scenes
const DIM_X = 9
const DIM_Y = 7

var curr_rooms = 0
var num_rooms = 20

var generation_queue = []

var max_neighbors = 1

const straight: PackedScene = preload("res://scenes/map/templates/straight_room_1.tscn")
const deadend: PackedScene = preload("res://scenes/map/templates/dead_end.tscn")
const turn: PackedScene = preload("res://scenes/map/templates/turn.tscn")
const threeway: PackedScene = preload("res://scenes/map/templates/threeway.tscn")
const full: PackedScene = preload("res://scenes/map/templates/fullroom.tscn")

func _ready() -> void:
	for i in DIM_X:
		grid.append([])
		structure.append([])
		for j in DIM_Y:
			grid[i].append(0)
			structure[i].append(null)
	
	start_gen()
	
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
	
	for i in range(DIM_Y):
		for j in range(DIM_X):
			if grid[j][i]:
				print(get_neighbors_array(grid, Vector2(j,i)))

func start_gen():
	var starting_room = Vector2(3,3)
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
				if randi_range(0, 1):
					continue
			# Random
			if randi_range(0, 1):
				if num_rooms < num_rooms - 5:
					continue
			if randi_range(0, 1):
				generation_queue.append(starting_room)
			
			# Create new room
			grid[neighbor.x][neighbor.y] = 1
			curr_rooms += 1
			generation_queue.append(neighbor)

const directions = [Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)]

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

func place_rooms():
	for i in range(DIM_X):
		for j in range(DIM_Y):
			if grid[i][j] == 1:
				var num_neighbors = get_num_neighbors(grid, Vector2(i,j))
				var neighbors_array = get_neighbors_array(grid, Vector2(i,j))
				
				var selected_room: BaseRoom = null
				
				if num_neighbors == 1:
					selected_room = deadend.instantiate()
				
				if num_neighbors == 2:
					if neighbors_array == ["A", "B", "A", "B"] or neighbors_array == ["B", "A", "B", "A"]:
						selected_room = straight.instantiate()
					else:
						selected_room = turn.instantiate()
				
				if num_neighbors == 3:
					selected_room = threeway.instantiate()
				
				if num_neighbors == 4:
					selected_room == full.instantiate()
				
				#if selected_room:
					#structure[i][j] = selected_room
					#selected_room.add_doors(neighbors_array, get_neighbors(Vector2(i,j)))
					#get_tree().root.add_child(selected_room)
