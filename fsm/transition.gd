extends Reference

class_name FSMTransition

# fsm : FSM
var fsm

# fsm : FSM
func _init(fsm):
	self.fsm = fsm

func pre_transition() -> void:
	pass

func post_transition() -> void:
	pass

func evaluate() -> bool:
	return false
