extends RayCast2D

func get_tilemap_tile_meta():
	return tilemap_tile_meta

var tilemap_tile_meta = {}
func get_collider():
	var collider = .get_collider()
	tilemap_tile_meta = {}
	if collider != null and collider is TileMap:
		var normal = get_collision_normal()
		var pos = get_collision_point()
		var id = collider.get_cellv(collider.world_to_map(pos-normal))
		var tile_meta = collider.tile_set.get_meta("tile_meta")
		if tile_meta.has(id):
			tilemap_tile_meta = tile_meta[id]
	
	return collider