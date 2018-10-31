extends "res://src/lut/ai/ai.gd"

#class_name FollowPathAI

export(NodePath) var MAP_PATH : NodePath
export(NodePath) var DRAWER : NodePath
export(NodePath) var CONTROLLER : NodePath

onready var drawer : Drawer = get_node(DRAWER)
onready var player : Android = get_parent().get_parent()
onready var map : TileMap = get_node(MAP_PATH)
onready var cont : AIController = get_node(CONTROLLER)

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
	graph.set_map(map, player_info, map_info)
	nav.set_graph(graph)
	
	fsm.connect("state_changed", self, "update_stream")
	
	fsm.add_transition(state_switch, state_walk, same_ground_level)
	fsm.add_transition(state_switch, state_jump_up, needs_jump)
	fsm.add_transition(state_switch, state_fall_down, needs_fall)
	
	fsm.add_transition(state_walk, state_switch, reached_node)
	fsm.add_transition(state_jump_up, state_switch, reached_node)
	fsm.add_transition(state_fall_down, state_switch, reached_node)

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
	if current.x < next.x: cont.press(cont.RIGHT)
	else: cont.press(cont.LEFT)

func release_directions() -> void:
	cont.release(cont.RIGHT)
	cont.release(cont.LEFT)

var state_none : FSMQuickState = FSMQuickState.new(fsm)\
	.add_enter(self, "state_none_enter")
func state_none_enter(from_state : FSMState) -> void:
	release_directions()
	cont.release(cont.UP)
	cont.release(cont.DOWN)
	cont.release(cont.JUMP)

var state_switch : FSMQuickState = FSMQuickState.new(fsm)\
	.add_enter(self, "state_switch_enter")
func state_switch_enter(from_state : FSMState) -> void:
	path_stream.next()
	if (path_stream.peek() == null): fsm.state(state_none)

var state_walk : FSMQuickState = FSMQuickState.new(fsm)\
	.add_enter(self, "state_walk_enter")
func state_walk_enter(from_state : FSMState) -> void:
	release_directions()
	cont.release(cont.JUMP)
	press_direction(path_stream.current(), path_stream.peek())
	

var state_jump_up : FSMQuickState = FSMQuickState.new(fsm)\
	.add_enter(self, "state_jump_up_enter")
func state_jump_up_enter(from_state : FSMState) -> void:
	release_directions()
	if path_stream.current().x != path_stream.peek().x:
		press_direction(path_stream.current(), path_stream.peek())
	cont.press(cont.JUMP)

var state_fall_down : FSMQuickState = FSMQuickState.new(fsm)\
	.add_enter(self, "state_fall_down_enter")
func state_fall_down_enter(from_state : FSMState) -> void:
	cont.release(cont.JUMP)
	release_directions()
	if path_stream.current().x != path_stream.peek().x:
		press_direction(path_stream.current(), path_stream.peek())

var reached_node : FSMQuickTransition = FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "reached_node_evaluation")
func reached_node_evaluation() -> bool:
	if path_stream.peek(2) != null && reached_node(path_stream.peek(), path_stream.peek(2)):
		#path_stream.next()
		return true
	
	return reached_node(path_stream.current(), path_stream.peek())

func reached_node(curr, next) -> bool:
	var p : Vector2 = map.world_to_map(player.global_position)
	var reached_x : bool
	if next.x > curr.x: reached_x = p.x >= next.x
	else: reached_x = p.x <= next.x
	
	var reached_y : bool
	if next.y < curr.y: reached_y = p.y <= next.y
	else: reached_y = p.y >= next.y
	
	return reached_x && reached_y

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



func _process(delta : float) -> void:
	if len(path) == 0:
		return
	
	if drawer:
		drawer.drawpath(map, path)

	fsm.update(delta)









