extends Reference

class_name FSM

var global_state : FSMState = null
var state : FSMState = null

#warning-ignore: unused_class_variable
var object : Object = null
var delta : float = 0

var previous_state : FSMState = null setget , get_previous_state

var skip_next_transition : int = 0
var transitions = {} # Dictionary

signal state_changed(fsm, from_state, to_state)

func add_transition(from_state : FSMState, to_state : FSMState, transition : FSMTransition) -> void:
	if !transitions.has(from_state):
		transitions[from_state] = {}
	
	if !transitions[from_state].has(to_state):
		transitions[from_state][to_state] = []
		
	transitions[from_state][to_state].append(transition)

func get_transition(from_state : FSMState): # -> null or Dictionary
	if from_state == null: return null
	if !transitions.has(from_state): return null
	
	for to_state in transitions[from_state]:
		var ts : FSMTransition = transitions[from_state][to_state]
		for transition in ts:
			if transition.evaluate():
				return {to_state = to_state, transition = transition}
	
	return null

func get_previous_state() -> FSMState:
	return previous_state

func skip_next_transition(num : int = 1) -> void:
	skip_next_transition += num

func transition() -> bool:
	var t = get_transition(state) # null or Dictionary
	if !t:
		return false
	
	if skip_next_transition > 0:
		skip_next_transition -= 1
		return false
	
	t.transition.pre_transition()
	state(t.to_state)
	t.transition.post_transition()

	return true

func update(delta : float) -> void:
	self.delta = delta
	
	if transition():
		return
	
	if global_state:
		global_state.main()
	
	if state:
		state.main()

#warning-ignore: function_conflicts_variable
func state(new_state : FSMState) -> void:
	if state:
		state.on_exit(new_state)
	
	previous_state = state
	state = new_state
	emit_signal("state_changed", self, previous_state, state)
	
	if state:
		state.on_enter(previous_state)

func revert_to_previous_state() -> void:
	state(previous_state)











