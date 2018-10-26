extends FSMTransition

class_name FSMInvertDecorator

var transition : FSMTransition
func _init(fsm : FSM, transition : FSMTransition).(fsm):
	self.transition = transition

func evaluate() -> bool:
	return !(transition.evaluate())