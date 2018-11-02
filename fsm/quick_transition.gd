extends FSMTransition

class_name FSMQuickTransition

func _init(fsm : FSM).(fsm):
	pass

var evaluate_func : FuncRef = funcref(self, "only_false")

func set_evaluation(object : Object, function : String) -> FSMQuickTransition:
	evaluate_func = funcref(object, function)
	return self

func set_to_always_true() -> FSMQuickTransition:
	evaluate_func = funcref(self, "only_true")
	return self

func evaluate() -> bool:
	return evaluate_func.call_func()

func only_false() -> bool:
	return false

func only_true() -> bool:
	return true
