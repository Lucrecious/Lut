extends Reference

var global_state = null
var state = null
var object = null
var delta = null

var previous_state = null setget , get_previous_state

var transitions = {}

func add_transition(from_state, to_state, transition):
	if !transitions.has(from_state):
		transitions[from_state] = {}
	
	if !transitions[from_state].has(to_state):
		transitions[from_state][to_state] = []
		
	transitions[from_state][to_state].append(transition)

func get_transition(from_state):
	if from_state == null: return null
	if !transitions.has(from_state): return null
	
	for to_state in transitions[from_state]:
		var ts = transitions[from_state][to_state]
		for transition in ts:
			if transition.evaluate():
				return {to_state = to_state, transition = transition}
	
	return null

func get_previous_state():
	return previous_state

func transition():
	var t = get_transition(state)
	if t:
		t.transition.pre_transition()
		state(t.to_state)
		t.transition.post_transition()
		return true
	
	return false

func update(delta):
	self.delta = delta
	
	if transition():
		return
	
	if global_state:
		global_state.main()
	
	if state:
		state.main()

func state(new_state):
	if state:
		state.on_exit(new_state)
	
	previous_state = state
	state = new_state
	
	if state:
		state.on_enter(previous_state)

func revert_to_previous_state():
	state(previous_state)











