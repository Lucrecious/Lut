extends Reference

class_name FSMState

# fsm : FSM
var fsm

# fsm : FSM
func _init(fsm):
	self.fsm = fsm

#warning-ignore: unused_argument
func on_enter(from_state : FSMState) -> void:
	pass

#warning-ignore: unused_argument
func main() -> void:
	pass

func on_exit(to_state : FSMState) -> void:
	pass
