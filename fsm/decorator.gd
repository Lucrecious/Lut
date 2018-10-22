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
	
	func pre_transition():
		t1.pre_transition()
		t2.pre_transition()
	
	func post_transition():
		t1.post_transition()
		t2.post_transition()

class Or extends "res://src/lut/fsm/transition.gd":
	var t1
	var t2
	func _init(fsm, t1, t2).(fsm):
		self.t1 = t1
		self.t2 = t2
	
	var evaluated
	func evaluate():
		if t1.evaluate():
			evaluated = t1
			return true
		
		if t2.evaluate():
			evaluated = t2
			return true
		
		return false
	
	func pre_transition():
		evaluated.pre_transition()
	
	func post_transition():
		evaluated.post_transition()
	
	
