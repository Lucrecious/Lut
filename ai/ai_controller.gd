extends Node

var actions = {}
var queued_pressed_actions = []
var queued_released_actions = []

enum { JUST_PRESSED, PRESSED, JUST_RELEASED, RELEASED }

enum { LEFT, RIGHT, UP, DOWN, JUMP, ATTACK, HOLD, DODGE }

func press(action):
	queued_pressed_actions.push_back(action)

func release(action):
	queued_released_actions.push_back(action)

func get_status(action):
	if !actions.has(action):
		return RELEASED
	
	return actions[action]

func update_status():
	for a in actions:
		match actions[a]:
			JUST_PRESSED: actions[a] = PRESSED
			JUST_RELEASED: actions[a] = RELEASED
	
	while !queued_released_actions.empty():
		var action = queued_released_actions.pop_back()
		var status = get_status(action)
		if status == JUST_RELEASED || status == RELEASED:
			continue
		
		actions[action] = JUST_RELEASED
	
	while !queued_pressed_actions.empty():
		var action = queued_pressed_actions.pop_back()
		actions[action] = JUST_PRESSED
		

func pressing_left():
	var status = get_status(LEFT)
	return status == JUST_PRESSED || status == PRESSED

func pressing_right():
	var status = get_status(RIGHT)
	return status == JUST_PRESSED || status == PRESSED

func left_right_direction():
	return int(pressing_right()) - int(pressing_left())

func just_pressed_up():
	return get_status(UP) == JUST_PRESSED

func pressing_up():
	return get_status(UP) == PRESSED

func just_pressed_down():
	return get_status(DOWN) == JUST_PRESSED

func pressing_down():
	return get_status(DOWN) == PRESSED

func just_pressed_jump():
	return get_status(JUMP) == JUST_PRESSED

func just_released_jump():
	return get_status(JUMP) == JUST_RELEASED

func just_pressed_dodge():
	return get_status(DODGE) == JUST_PRESSED

func just_pressed_attack():
	return get_status(ATTACK) == JUST_PRESSED

func just_held_direction():
	return get_status(HOLD) == JUST_PRESSED

func just_released_direction():
	return get_status(HOLD) == JUST_RELEASED

func holding_direction():
	return get_status(HOLD) == PRESSED
	
func _physics_process(delta):
	update_status()
