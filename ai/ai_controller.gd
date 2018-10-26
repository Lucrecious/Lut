extends Node

class_name AIController

var actions : Dictionary = {}
var queued_pressed_actions : Array = []
var queued_released_actions : Array = []

enum { JUST_PRESSED, PRESSED, JUST_RELEASED, RELEASED }

enum { LEFT, RIGHT, UP, DOWN, JUMP, ATTACK, HOLD, DODGE }

# Action enum
func press(action) -> void:
	queued_pressed_actions.push_back(action)

# Action enum
func release(action) -> void:
	queued_released_actions.push_back(action)

# Action enum
func get_status(action): # -> Status enum
	if !actions.has(action):
		return RELEASED
	
	return actions[action]

func update_status() -> void:
	for a in actions:
		match actions[a]:
			JUST_PRESSED: actions[a] = PRESSED
			JUST_RELEASED: actions[a] = RELEASED
	
	while !queued_released_actions.empty():
		var action := queued_released_actions.pop_back()
		var status = get_status(action)
		if status == JUST_RELEASED || status == RELEASED:
			continue
		
		actions[action] = JUST_RELEASED
	
	while !queued_pressed_actions.empty():
		var action := queued_pressed_actions.pop_back()
		actions[action] = JUST_PRESSED
		

func pressing_left() -> bool:
	var status = get_status(LEFT)
	return status == JUST_PRESSED || status == PRESSED

func pressing_right() -> bool:
	var status = get_status(RIGHT)
	return status == JUST_PRESSED || status == PRESSED

func left_right_direction() -> int:
	return int(pressing_right()) - int(pressing_left())

func just_pressed_up() -> bool:
	return get_status(UP) == JUST_PRESSED

func pressing_up() -> bool:
	return get_status(UP) == PRESSED

func just_pressed_down() -> bool:
	return get_status(DOWN) == JUST_PRESSED

func pressing_down() -> bool:
	return get_status(DOWN) == PRESSED

func just_pressed_jump() -> bool:
	return get_status(JUMP) == JUST_PRESSED

func just_released_jump() -> bool:
	return get_status(JUMP) == JUST_RELEASED

func just_pressed_dodge() -> bool:
	return get_status(DODGE) == JUST_PRESSED

func just_pressed_attack() -> bool:
	return get_status(ATTACK) == JUST_PRESSED

func just_held_direction() -> bool:
	return get_status(HOLD) == JUST_PRESSED

func just_released_direction() -> bool:
	return get_status(HOLD) == JUST_RELEASED

func holding_direction() -> bool:
	return get_status(HOLD) == PRESSED
	
func _physics_process(delta : float) -> void:
	update_status()
