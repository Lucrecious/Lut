extends Thread

var start
var goal
var nav_map

var finished = true

func is_finished():
	return finished

func tstart(start, goal, timeout=INF):
	if is_active() and finished:
		return ERR_CANT_CREATE
	
	self.start = start
	self.goal = goal
	
	finished = false
	
	return start(self, "compute", timeout)

func _init(nav_map):
	self.nav_map = nav_map

# the max height in 40x40px blocks
var jump_height = 3

# The number of height blocks before a horizontal move
var air_vel_rate = 5

var Tile = Game.NavigationMaps.Tile

func h(a, b):
	return abs(Tile.x(b) - Tile.x(a)) + abs(Tile.y(b) - Tile.y(a))

func g(a, b):
	return 1 + Tile.jump(b) / 4

func get_minimum_fscore(open_set, fscore):
	var m = INF
	var out = null
	for v in open_set:
		if fscore[v] < m:
			m = fscore[v]
			out = v
	
	return out

func can_fit(tile):
	return true

func on_ground(tile):
	var tile_below = nav_map.tile(Tile.x(tile), Tile.y(tile) + 1)
	var tile_on = nav_map.tile(Tile.x(tile), Tile.y(tile))
	return Tile.type(tile_below) == nav_map.GROUND ||\
			(Tile.type(tile_below) == nav_map.CLIMB && Tile.type(tile_on) == nav_map.AIR)

func on_climb(tile):
	return Tile.type(tile) == nav_map.CLIMB

func at_ceiling(tile):
	var tile_above = nav_map.tile(Tile.x(tile), Tile.y(tile) - 1)
	return Tile.type(tile_above) == nav_map.GROUND

func get_neighbours(tile):
	var possible_neighbours = nav_map.neighbours(Tile.x(tile), Tile.y(tile))
	var neighbours = []
	var on_ground
	var on_climb
	var at_ceiling
	
	var max_jump_height = jump_height * air_vel_rate
	var avr = air_vel_rate
	
	for n in possible_neighbours:
		if !can_fit(n):
			continue
		
		on_ground = on_ground(n)
		on_climb = on_climb(n)
		at_ceiling = at_ceiling(n)
		
		# calculating the jump
		var jump_length = Tile.jump(tile)
		var new_jump_length = jump_length
		var ar = int(jump_length) % avr
		
		if on_ground || on_climb:
			new_jump_length = 0
		elif at_ceiling:
			if Tile.x(tile) != Tile.x(n):
				new_jump_length = max(max_jump_height + 1, jump_length + 1)
			else:
				new_jump_length = max(max_jump_height, jump_length + avr)
		elif Tile.y(n) < Tile.y(tile):
			if jump_length < 2:
				new_jump_length = avr * 2 - 1
			else:
				new_jump_length = Math.ceil_to(jump_length + 1, avr)
			#elif ar == 0:
			#	new_jump_length = jump_length + avr
			#else:
			#	new_jump_length = jump_length + avr + 1
		elif Tile.y(n) > Tile.y(tile):
			var next_jump = Math.ceil_to(jump_length + 1, avr)
			if ar == 0:
				new_jump_length = max(max_jump_height, next_jump)
			else:
				new_jump_length = max(max_jump_height + 1, next_jump)
		elif (!on_ground || !on_climb) && Tile.x(n) != Tile.x(tile):
			if Tile.type(tile) == nav_map.CLIMB:
				new_jump_length = max_jump_height + 1
			else:
				new_jump_length = jump_length + 1
		
		# validation
		
		# can't move left/right during jump on odd number
		if ar != 0 and Tile.x(tile) != Tile.x(n):
			continue
		
		# only fall after max jump height reached
		if jump_length >= max_jump_height and Tile.y(n) < Tile.y(tile):
			continue
		
		# start only being able to move down after some threshold
		if new_jump_length >= max_jump_height + 6 && Tile.x(n) != Tile.x(tile) \
		 && int((new_jump_length - (max_jump_height + 6))) % 8 != 3:
		 		continue;
		
		n = Tile.set_jump(n, new_jump_length)
		neighbours.append(n)
		
	
	return neighbours

func move_around(curr, path):
	var left_type = Tile.type(nav_map.tile(Tile.x(curr) - 1, Tile.y(curr)))
	var right_type = Tile.type(nav_map.tile(Tile.x(curr) + 1, Tile.y(curr)))
	
	var y_aligned = Tile.y(curr) == Tile.y(path[path.size() - 1])
	var x_aligned = Tile.x(curr) == Tile.x(path[path.size() - 1])
	
	return (left_type == nav_map.GROUND || right_type == nav_map.GROUND) &&\
			!x_aligned && !y_aligned
	
	

func filter(path):
	if path.size() == 0: return []
	
	var filtered = [path[0]]
	
	for i in range(1, path.size() - 1):
		var prev = path[i - 1]
		var curr = path[i]
		var next= path[i + 1]
		
		var jump_begin = Tile.jump(curr) == 0 && Tile.jump(next) != 0
		var first_air = Tile.jump(curr) == air_vel_rate * 2 - 1
		var land = Tile.jump(prev) != 0 && Tile.jump(curr) == 0
		var highest = Tile.y(curr) < Tile.y(filtered[filtered.size() -1]) &&\
						Tile.y(curr) < Tile.y(next)
		var change_type = Tile.type(prev) != Tile.type(curr)
		
		if jump_begin || first_air || land || highest || change_type || move_around(curr, filtered):
				filtered.append(curr)
	
	filtered.append(path[path.size() - 1])
	
	return filtered

func construct_path(came_from, current):
	var total_path = [current]
	while came_from.has(current):
		current = came_from[current]
		total_path.push_front(current)
	
	var filtered = filter(total_path)

	return filtered

func compute(timeout):
	var path = null
	
	var closed_set = {}
	var open_set = {start:null}
	var came_from = {}
	var gscore = {start:0}
	var fscore = {start:h(start, goal)}
	
	var start_time = OS.get_ticks_msec()
	
	while !open_set.empty() && OS.get_ticks_msec() < start_time + timeout:
		var current = get_minimum_fscore(open_set, fscore)
		
		if Tile.x(current) == Tile.x(goal) && Tile.y(current) == Tile.y(goal):
			path = construct_path(came_from, current)
			break
		
		open_set.erase(current)
		closed_set[current] = null
		
		for n in get_neighbours(current):
			if closed_set.has(n):
				continue
			
			if !open_set.has(n):
				open_set[n] = null
			
			var tmp_gscore = gscore[current] + g(current, n)
			
			if gscore.has(n) && tmp_gscore >= gscore[n]:
				continue
			
			came_from[n] = current
			gscore[n] = tmp_gscore
			fscore[n] = tmp_gscore + h(n, goal)
	
	finished = true
	return path









