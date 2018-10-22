extends Node

export(int, "Loop", "Random") var ITERATION_TYPE = 0

onready var current_child = 0
onready var children_num = get_child_count()

func iteration():
	match ITERATION_TYPE:
		0: return (current_child + 1) % children_num
		1: return randi()%children_num
	
	return current_child

func play(from_position=0.0):
	get_child(current_child).play(from_position)
	current_child = iteration()
