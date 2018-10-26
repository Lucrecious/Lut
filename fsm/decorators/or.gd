extends FSMTransition

class_name FSMOrDecorator

var t1 : FSMTransition
var t2 : FSMTransition
func _init(fsm : FSM, t1 : FSMTransition, t2 : FSMTransition).(fsm):
	self.t1 = t1
	self.t2 = t2

var evaluated : FSMTransition
func evaluate() -> bool:
	if t1.evaluate():
		evaluated = t1
		return true
	
	if t2.evaluate():
		evaluated = t2
		return true
	
	return false

func pre_transition() -> void:
	evaluated.pre_transition()

func post_transition() -> void:
	evaluated.post_transition()

