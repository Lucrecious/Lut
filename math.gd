extends Node

class_name LutMath

static func jumping_gravity(height : float, time : float) -> float:
	time = height*time
	return (2*height*Game.BLOCK_SIZE)/(time * time)

static func jump_impulse(height : float, time : float) -> float:
	time = height*time
	return (2*height*Game.BLOCK_SIZE) / time

static func solve_quadratic(a: float = 0.0, b : float = 0.0, c : float = 0.0) -> Array:
	var left : float = sqrt(b*b - 4*a*c)/(2*a)
	var right : float = -b/(2*a)
	return [right - left, right + left]

static func round_to(num : float, div : int) -> int:
	return int(round(num/div)*div)

static func ceil_to(num : float, div : int) -> int:
	return int(ceil(num/div)*div)

static func floor_to(num : float, div : int) -> int:
	return int(floor(num/div)*div)