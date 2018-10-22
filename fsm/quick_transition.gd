extends "res://src/lut/fsm/transition.gd"

func _init(fsm).(fsm):
	pass

var evaluate_func = funcref(self, "only_false")

func set_evaluation(object, function):
	evaluate_func = funcref(object, function)
	return self

func evaluate():
	return evaluate_func.call_func()

func only_false():
	return false
