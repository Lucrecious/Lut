extends Node

class_name SoundIterator

export(int, "Loop", "Random") var ITERATION_TYPE : int = 0

onready var current_child : int = 0
onready var children_num : int = get_child_count()

func iteration() -> int:
	match ITERATION_TYPE:
		0: return (current_child + 1) % children_num
		1: return randi()%children_num
	
	return current_child

func play(from_position : float = 0.0) -> void:
	get_child(current_child).play(from_position)
	current_child = iteration()
