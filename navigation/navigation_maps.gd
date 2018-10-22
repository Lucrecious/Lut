extends Node

const Tile = preload("res://src/lut/navigation/tile.gd")

enum { AIR, GROUND, HAZARD, CLIMB }

export(int) var HAZARD_TILE_ID = 0
export(int) var GROUND_TILE_ID = 2
export(int) var CLIMB_TILE_ID = 3

var types = {
	HAZARD_TILE_ID : HAZARD,
	GROUND_TILE_ID : GROUND,
	CLIMB_TILE_ID : CLIMB,
	-1 : AIR
}

onready var map = get_child(0)

func world_pos(map_pos):
	return map.map_to_world(map_pos)

func map_pos(world_pos):
	return map.world_to_map(world_pos)

func tile(x, y):
	return Tile.create(x, y, 0, 0, types[map.get_cell(x, y)])

func is_collision(x, y):
	return Tile.type(tile(x, y)) == GROUND

func neighbours(x, y):
	var neighbours = []
	
	for i in [-1, 1]:
		for on_y in [false, true]:
			var xi = x if on_y else x + i
			var yi = y + i if on_y else y
			if !is_collision(xi, yi):
				neighbours.append(tile(xi, yi))

	return neighbours










