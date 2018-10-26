extends FSMTransition

class_name FSMAndDecorator

var t1 : FSMTransition
var t2 : FSMTransition
func _init(fsm : FSM, t1 : FSMTransition, t2 : FSMTransition).(fsm):
	self.t1 = t1
	self.t2 = t2

func evaluate() -> bool:
	return t1.evaluate() and t2.evaluate()

func pre_transition() -> void:
	t1.pre_transition()
	t2.pre_transition()

func post_transition() -> void:
	t1.post_transition()
	t2.post_transition()