extends "res://src/lut/ai/ai.gd"

export(NodePath) var NAVIGATION_MAPS_PATH
export(NodePath) var DRAWER

onready var nav_map = get_node(NAVIGATION_MAPS_PATH)
onready var drawer = get_node(DRAWER)
onready var player = get_parent().get_parent()

const path_timeout = 1000

onready var path_thread = Game.NavigationPath.new(nav_map)
var path = null

var fsm = Game.FSM.new()

var state_wait_thread = Game.FSM.QuickState.new(fsm)\
	.add_exit(self, "state_wait_thread_exit")
func state_wait_thread_exit(to_state):
	path = path_thread.wait_to_finish()

var path_computed = Game.FSM.QuickTransition.new(fsm)\
	.set_evaluation(self, "path_thread_finished")
func path_thread_finished():
	return path_thread.is_finished()
	

func _ready():
	fsm.object = self
	fsm.add_transition(state_wait_thread, null, path_computed)


func _input(event):
	if not path_thread.is_active() and event is InputEventMouseButton:
		if !event.doubleclick: return
		
		var start = nav_map.map_pos(player.global_position)
		var end = nav_map.map_pos(drawer.get_global_mouse_position())
		
		path_thread.tstart(
			nav_map.tile(start.x, start.y),
			nav_map.tile(end.x, end.y),
			path_timeout)
		
		fsm.state(state_wait_thread)

func _process(delta):
	fsm.update(delta)
	
	if not path:
		return
	
	if drawer:
		drawer.drawpath(nav_map, path)
	
	
	