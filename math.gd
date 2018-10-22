extends Node

func jumping_gravity(height, time):
	time = height*time
	return (2*height*Game.BLOCK_SIZE)/(time * time)

func jump_impulse(height, time):
	time = height*time
	return (2*height*Game.BLOCK_SIZE) / time

func solve_quadratic(a=0, b=0, c=0):
	var left = sqrt(b*b - 4*a*c)/(2*a)
	var right = -b/(2*a)
	return [right - left, right + left]

func round_to(num, div):
	return round(num/div)*div

func ceil_to(num, div):
	return ceil(num/div)*div

func floor_to(num, div):
	return floor(num/div)*div