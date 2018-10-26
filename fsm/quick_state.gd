extends FSMState

class_name FSMQuickState

var on_exits : Array = []
var on_enters : Array = []
var mains : Array = []

func add_exit(obj : Object, f : String) -> FSMQuickState:
	on_exits.append(funcref(obj, f))
	return self

func add_main(obj : Object, f : String) -> FSMQuickState:
	mains.append(funcref(obj, f))
	return self

func add_enter(obj : Object, f : String) -> FSMQuickState:
	on_enters.append(funcref(obj, f))
	return self

func _init(fsm : FSM).(fsm):
	pass

func on_enter(from_state : FSMState) -> void:
	for enter in on_enters:
		enter.call_func(from_state)

func main() -> void:
	for m in mains:
		m.call_func()

func on_exit(to_state : FSMState) -> void:
	for exit in on_exits:
		exit.call_func(to_state)


