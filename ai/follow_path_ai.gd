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
		
		path = nav.compute(start, goal, true)
		index = -1
		fsm.state(picker)

var fsm : FSM = FSM.new()
var index : int
var current
var next

var picker : FSMQuickState = FSMQuickState.new(fsm).add_enter(self, "picker_enter")
func picker_enter(from_state : FSMState) -> void:
	index += 1
	if index >= path.size() - 1:
		fsm.state(null)
		return
	
	current = path[index]
	next = path[index + 1]


func press_direction(current, next) -> void:
	if current.x < next.x: cont.press(cont.RIGHT)
	else: cont.press(cont.LEFT)

func release_directions() -> void:
	cont.release(cont.RIGHT)
	cont.release(cont.LEFT)


func _process(delta : float) -> void:
	if len(path) == 0:
		return
	
	if drawer:
		drawer.drawpath(map, path)

	fsm.update(delta)









