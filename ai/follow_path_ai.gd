extends "res://src/lut/ai/ai.gd"

#class_name FollowPathAI

export(NodePath) var MAP_PATH : NodePath
export(NodePath) var DRAWER : NodePath

onready var drawer : Drawer = get_node(DRAWER)
onready var player : Android = get_parent().get_parent()
onready var map : TileMap = get_node(MAP_PATH)

const path_timeout : int = 1000

var path : Array = []

var nav : CharacterAStar = CharacterAStar.new()
var graph : CharacterGraph = CharacterGraph.new()
	
var player_info : PlayerInfo = PlayerInfo.new()
var map_info : MapInfo = MapInfo.new()

func _ready() -> void:
	fsm.object = self
	
	player_info.air_velocity_rate = 5
	player_info.jump_height = 3
		
	map_info.none = -1
	map_info.air = 0
	map_info.ground = 2
	map_info.climb = 3
	map_info.wall = 4
	graph.set_map(map, player_info, map_info)
	nav.set_graph(graph)
	
	fsm.connect("state_changed", self, "update_stream")
	
	var reached_node_and_on_ground : FSMTransition =\
	FSMAndDecorator.new(fsm, reached_node, player_on_ground)
	
	var needs_wall_jump_or_on_wall_jump_node : FSMTransition =\
	FSMOrDecorator.new(fsm, needs_wall_jump, on_wall_jump_node)
	
	fsm.add_transition(state_switch, state_walk, same_ground_level)
	
	fsm.add_transition(state_switch, state_wall_jump, needs_wall_jump_or_on_wall_jump_node)
	fsm.add_transition(state_wall_jump, state_wall_jump, needs_wall_jump)
	
	fsm.add_transition(state_switch, state_climb_up, needs_climb_up)
	fsm.add_transition(state_switch, state_climb_top, needs_climb_top)
	fsm.add_transition(state_switch, state_climb_bottom, needs_climb_bottom)
	fsm.add_transition(state_switch, state_climb_down, needs_climb_down)
	
	fsm.add_transition(state_switch, state_climb_jump_off_prep, needs_climb_jump_off)
	fsm.add_transition(state_climb_jump_off_prep, state_jump_off, finish_climb_jump_off_prep)
	
	fsm.add_transition(state_switch, state_jump_up, needs_jump)
	fsm.add_transition(state_switch, state_fall_down, needs_fall)
	
	fsm.add_transition(state_walk, state_switch, reached_node)
	fsm.add_transition(state_jump_up, state_switch, reached_node)
	fsm.add_transition(state_fall_down, state_switch, reached_node)
	
	fsm.add_transition(state_wall_jump, state_switch, reached_node_above)
	
	fsm.add_transition(state_jump_off, state_switch, reached_node)
	fsm.add_transition(state_climb_up, state_switch, reached_node)
	fsm.add_transition(state_climb_top, state_switch, reached_node_and_on_ground)
	fsm.add_transition(state_climb_down, state_switch, reached_node)
	fsm.add_transition(state_climb_bottom, state_switch, reached_node_and_on_ground)

func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.doubleclick: return
		
		var startv : Vector2 = map.world_to_map(player.global_position)
		var goalv : Vector2 = map.world_to_map(drawer.get_global_mouse_position())
		
		var start : CharacterNode = CharacterNode.new()
		start.x = startv.x
		start.y = startv.y
		
		var goal : CharacterNode = CharacterNode.new()
		goal.x = goalv.x
		goal.y = goalv.y
		
		path = nav.compute(start, goal, true, false)
		path_stream = PathStream.new(path)
		
		#print("path")
		#for n in path:
		#	print(n.x, " ", n.y, " ", n.jump, " ", n.type == map_info.climb, " ", n.type)
		
		fsm.state(state_switch)

var fsm : FSM = FSM.new()
var path_stream : PathStream
class PathStream:
	var index : int
	var path : Array
	
	func _init(path : Array):
		self.path = path
		self.index = -1
	
	func peek(ahead : int = 1) -> Object:
		if ahead < 1:
			printerr("ahead must be greater than 0")
			return null

		if index + ahead >= len(path): return null
		
		return path[index + ahead]
	
	func next() -> Object:
		index += 1
		return current()
	
	func current() -> Object:
		if finished(): return null
		if index == -1:
			printerr("must call next before first current call")
			return null
		
		return path[index]
	
	func finished() -> bool:
		return index >= len(path)

func press_direction(current, next) -> void:
	#var px : int = map.world_to_map(player.global_position).x
	if current.x < next.x: cont.press(cont.RIGHT)
	elif current.x > next.x: cont.press(cont.LEFT)
	else: cont.release_many([cont.RIGHT, cont.LEFT])

# States

var state_none : FSMQuickState = FSMQuickState.new(fsm)\
	.add_enter(self, "state_none_enter")
func state_none_enter(from_state : FSMState) -> void:
	cont.release_all()

var state_switch : FSMQuickState = FSMQuickState.new(fsm)\
	.add_enter(self, "state_switch_enter")
func state_switch_enter(from_state : FSMState) -> void:
	path_stream.next()
	if (path_stream.peek() == null): fsm.state(state_none)

var state_walk : FSMQuickState = FSMQuickState.new(fsm)\
	.add_enter(self, "state_walk_enter")
func state_walk_enter(from_state : FSMState) -> void:
	cont.release_all()
	press_direction(path_stream.current(), path_stream.peek())

var state_jump_up : FSMQuickState = FSMQuickState.new(fsm)\
	.add_enter(self, "state_jump_up_enter")
func state_jump_up_enter(from_state : FSMState) -> void:
	cont.release_many([cont.LEFT, cont.RIGHT, cont.UP, cont.DOWN])
	press_direction(path_stream.current(), path_stream.peek())
	cont.press(cont.JUMP)

var state_fall_down : FSMQuickState = FSMQuickState.new(fsm)\
	.add_enter(self, "state_fall_down_enter")
func state_fall_down_enter(from_state : FSMState) -> void:
	cont.release_all()
	press_direction(path_stream.current(), path_stream.peek())

var state_climb_up : FSMQuickState = FSMQuickState.new(fsm)\
	.add_enter(self, "state_climb_up_enter")
func state_climb_up_enter(from_state : FSMState) -> void:
	cont.release_all()
	cont.press(cont.UP)

var state_climb_top : FSMQuickState = FSMQuickState.new(fsm)\
	.add_enter(self, "state_climb_top_enter")
func state_climb_top_enter(from_state : FSMState) -> void:
	cont.release_all()
	cont.press(cont.UP)

var state_climb_down : FSMQuickState = FSMQuickState.new(fsm)\
	.add_enter(self, "state_climb_down_enter")
func state_climb_down_enter(from_state : FSMState) -> void:
	cont.release_all()
	cont.press(cont.DOWN)

var state_climb_bottom : FSMQuickState = FSMQuickState.new(fsm)\
	.add_enter(self, "state_climb_bottom_enter")
func state_climb_bottom_enter(from_state : FSMState) -> void:
	cont.release_all()
	cont.press(cont.DOWN)

var state_climb_jump_off_prep : FSMQuickState = FSMQuickState.new(fsm)\
	.add_enter(self, "state_climb_jump_off_prep_enter")
func state_climb_jump_off_prep_enter(from_state : FSMState) -> void:
	cont.release_all()
	cont.press(cont.UP)

var state_jump_off : FSMQuickState = FSMQuickState.new(fsm)\
	.add_enter(self, "state_jump_off_enter")
func state_jump_off_enter(from_state : FSMState) -> void:
	cont.release_all()
	cont.press(cont.JUMP)
	press_direction(path_stream.current(), path_stream.peek())

func vwall_direction(x : float, y : float) -> int:
	if map.get_cell(x + 1, y) == map_info.wall: return 1;
	if map.get_cell(x - 1, y)  == map_info.wall: return -1;
	
	return 0

func wall_direction(current) -> int:
	return vwall_direction(current.x, current.y)

var state_wall_jump : FSMQuickState = FSMQuickState.new(fsm)\
	.add_enter(self, "state_wall_jump_enter")
func state_wall_jump_enter(from_state : FSMState) -> void:
	print("enter_wall_jump")
	cont.release_all()
	if wall_direction(path_stream.current()) < 0: cont.press(cont.LEFT)
	else: cont.press(cont.RIGHT)
	cont.press(cont.JUMP)


# Transitions

func reached_node(curr, next) -> bool:
	return vreached_node(curr.x, curr.y, next.x, next.y)

func vreached_node(x : float, y : float, nx : float, ny : float) -> bool:
	var p : Vector2 = map.world_to_map(player.global_position)
	var reached_x : bool
	if nx > x: reached_x = p.x >= nx
	elif nx < x: reached_x = p.x <= nx
	else: reached_x = p.x == nx
	
	var reached_y : bool
	if ny < y: reached_y = p.y <= ny
	elif ny > y: reached_y = p.y >= ny
	else: reached_y = p.y == ny
	
	return reached_x && reached_y

var reached_node : FSMQuickTransition = FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "reached_node_evaluation")
func reached_node_evaluation() -> bool:
	if path_stream.peek(2) != null && reached_node(path_stream.peek(), path_stream.peek(2)):
		#path_stream.next()
		return true
	
	return reached_node(path_stream.current(), path_stream.peek())

var reached_node_above : FSMQuickTransition = FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "reached_node_above_evaluation")
func reached_node_above_evaluation() -> bool:
	var current = path_stream.current()
	var next = path_stream.peek()
	return vreached_node(current.x, current.y, next.x, next.y - 1)

var player_on_ground : FSMQuickTransition = FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "player_on_ground_evaluation")
func player_on_ground_evaluation() -> bool:
	return player.is_on_floor()

var same_ground_level : FSMQuickTransition = FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "same_ground_level_evaluation")
func same_ground_level_evaluation() -> bool:
	return player.is_on_floor() and path_stream.current().y == path_stream.peek().y

var needs_jump : FSMQuickTransition = FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "needs_jump_evaluation")
func needs_jump_evaluation() -> bool:
	return path_stream.current().y > path_stream.peek().y

var needs_fall : FSMQuickTransition = FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "needs_fall_evaluation")
func needs_fall_evaluation() -> bool:
	return path_stream.current().y < path_stream.peek().y

var needs_climb_up : FSMQuickTransition = FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "needs_climb_up_evaluation")
func needs_climb_up_evaluation() -> bool:
	return path_stream.current().y - path_stream.peek().y > 0\
			&& path_stream.current().x == path_stream.peek().x\
			&& path_stream.peek().type == map_info.climb

var needs_climb_top : FSMQuickTransition = FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "needs_climb_top_evaluation")
func needs_climb_top_evaluation() -> bool:
	return path_stream.current().y - path_stream.peek().y > 0\
			&& path_stream.current().x == path_stream.peek().x\
			&& path_stream.current().type == map_info.climb\
			&& path_stream.peek().type == map_info.air

var needs_climb_down : FSMQuickTransition = FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "needs_climb_down_evaluation")
func needs_climb_down_evaluation() -> bool:
	return path_stream.peek().y - path_stream.current().y > 0\
			&& path_stream.current().x == path_stream.peek().x\
			&& path_stream.peek().type == map_info.climb

var needs_climb_bottom : FSMQuickTransition = FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "needs_climb_bottom_evaluation")
func needs_climb_bottom_evaluation() -> bool:
	return path_stream.peek().y - path_stream.current().y > 0\
			&& path_stream.current().x == path_stream.peek().x\
			&& path_stream.current().type == map_info.climb\
			&& map.get_cell(path_stream.peek().x, path_stream.peek().y + 1) == map_info.ground

var needs_climb_jump_off : FSMQuickTransition = FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "needs_climb_jump_off_evaluation")
func needs_climb_jump_off_evaluation() -> bool:
	return path_stream.current().x != path_stream.peek().x\
			&& path_stream.current().type == map_info.climb

var finish_climb_jump_off_prep : FSMQuickTransition = FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "finish_climb_jump_off_prep_evaluation")
func finish_climb_jump_off_prep_evaluation() -> bool:
	var py : int = map.world_to_map(player.global_position).y
	return py < path_stream.current().y - 1 or player.is_on_floor()

var needs_wall_jump : FSMQuickTransition = FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "needs_wall_jump_evaluation")
func needs_wall_jump_evaluation() -> bool:
	return wall_direction(path_stream.current()) != 0\
			&& (player.is_on_floor() || player.wall_sliding)

var on_wall_jump_node : FSMQuickTransition = FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "on_wall_jump_node_evaluation")
func on_wall_jump_node_evaluation() -> bool:
	var ppos : Vector2 = map.world_to_map(player.global_position)
	var current = path_stream.current()
	return wall_direction(current) != 0\
			&& ppos.x == current.x && ppos.y == current.y 

var always_true : FSMQuickTransition = FSMQuickTransition.new(fsm)\
	.set_to_always_true()



func _process(delta : float) -> void:
	if len(path) == 0:
		return
	
	if drawer:
		drawer.drawpath(map, path)

	fsm.update(delta)









