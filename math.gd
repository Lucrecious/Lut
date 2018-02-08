static func set_len(v, n):
	if (v.x == 0 && v.y == 0):
		return Vector2()
	
	var l = v.length()
	
	return Vector2(n*v.x/l, n*v.y/l)