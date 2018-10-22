extends Node

static func create(x, y, jump, jump_direction, tile_type):
	return Basis(Vector3(x, y, jump), Vector3(jump_direction, tile_type, 0), Vector3())

static func x(tile):
	return tile.x.x

static func y(tile):
	return tile.x.y

static func jump(tile):
	return tile.x.z

static func set_jump(tile, value):
	tile.x.z = value
	return tile

static func jump_direction(tile):
	return tile.y.x

static func type(tile):
	return tile.y.y
