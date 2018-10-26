extends "res://src/lut/ai/ai.gd"

export(NodePath) var MAP_PATH
export(NodePath) var DRAWER

onready var drawer = get_node(DRAWER)
onready var player = get_parent().get_parent()
onready var map = get_node(MAP_PATH)

const path_timeout = 1000

var path = null

var nav = CharacterAStar.new()
var graph = CharacterGraph.new()
	
var player_info = PlayerInfo.new()
var map_info = MapInfo.new()

func _ready():
	player_info.air_velocity_rate = 5
	player_info.jump_height = 3
		
	map_info.none = -1
	map_info.air = 0
	map_info.ground = 2
	map_info.climb = 3
	graph.set_map(map, player_info, map_info)
	nav.set_graph(graph)

func _input(event):
	if event is InputEventMouseButton:
		if !event.doubleclick: return
		
		var startv = map.world_to_map(player.global_position)
		var goalv = map.world_to_map(drawer.get_global_mouse_position())
		
		var start = CharacterNode.new()
		start.x = startv.x
		start.y = startv.y
		
		var goal = CharacterNode.new()
		goal.x = goalv.x
		goal.y = goalv.y
		
		path = nav.compute(start, goal, true)
		
		#for n in path:
			#print(n.x, " ", n.y, " ", n.jump)

func _process(delta):	
	if not path:
		return
	
	if drawer:
		drawer.drawpath(map, path)
	
	
	