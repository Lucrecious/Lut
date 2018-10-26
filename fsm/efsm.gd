extends FSM

signal enter_state
signal exit_state

# to_state : enum
func state(to_state) -> void:
	emit_signal("exit_state", state, to_state)
	
	# from_state : enum
	var from_state = state
	state = to_state
	emit_signal("enter_state", state, from_state)
	

func update(delta : float) -> void:
	self.delta = delta
	
	if transition():
		return
