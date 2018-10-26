extends Node

class_name LutMath

func jumping_gravity(height : float, time : float) -> float:
	time = height*time
	return (2*height*Game.BLOCK_SIZE)/(time * time)

func jump_impulse(height : float, time : float) -> float:
	time = height*time
	return (2*height*Game.BLOCK_SIZE) / time

func solve_quadratic(a: float = 0.0, b : float = 0.0, c : float = 0.0) -> Array:
	var left : float = sqrt(b*b - 4*a*c)/(2*a)
	var right : float = -b/(2*a)
	return [right - left, right + left]

func round_to(num : float, div : int) -> int:
	return int(round(num/div)*div)

func ceil_to(num : float, div : int) -> int:
	return int(ceil(num/div)*div)

func floor_to(num : float, div : int) -> int:
	return int(floor(num/div)*div)