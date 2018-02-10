extends "res://src/lut/fsm/state.gd"

var on_exits = []
var on_enters = []
var mains = []

func add_exit(obj, f):
	on_exits.append(funcref(obj, f))
	return self

func add_main(obj, f):
	mains.append(funcref(obj, f))
	return self

func add_enter(obj, f):
	on_enters.append(funcref(obj, f))
	return self

func _init(fsm).(fsm):
	pass

func on_enter(from_state):
	for enter in on_enters:
		enter.call_func(from_state)

func main():
	for m in mains:
		m.call_func()

func on_exit(to_state):
	for exit in on_exits:
		exit.call_func(to_state)


