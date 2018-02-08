extends "res://src/lut/fsm/fsm.gd"

signal enter_state
signal exit_state

func state(to_state):
	emit_signal("exit_state", state, to_state)
	var from_state = state
	state = to_state
	emit_signal("enter_state", state, from_state)
	

func update(delta):
	self.delta = delta
	
	if transition():
		return
