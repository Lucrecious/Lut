extends Reference

class Invert extends "res://src/lut/fsm/transition.gd":
	var transition
	func _init(fsm, transition).(fsm):
		self.transition = transition
	
	func evaluate():
		return !(transition.evaluate())

class And extends "res://src/lut/fsm/transition.gd":
	var t1
	var t2
	func _init(fsm, t1, t2).(fsm):
		self.t1 = t1
		self.t2 = t2
	
	func evaluate():
		return t1.evaluate() and t2.evaluate()

class Or extends "res://src/lut/fsm/transition.gd":
	var t1
	var t2
	func _init(fsm, t1, t2).(fsm):
		self.t1 = t1
		self.t2 = t2
	
	func evaluate():
		return t1.evaluate() or t2.evaluate()
