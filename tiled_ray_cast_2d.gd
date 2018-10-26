extends RayCast2D

class_name TiledRayCast2D

func get_tilemap_tile_meta():
	return tilemap_tile_meta

var tilemap_tile_meta : Dictionary = {}
func get_collider() -> Object:
	var collider : Object = .get_collider()
	tilemap_tile_meta = {}
	if collider != null and collider is TileMap:
		var normal : Vector2 = get_collision_normal()
		var pos : Vector2 = get_collision_point()
		var id : int = collider.get_cellv(collider.world_to_map(pos-normal))
		var tile_meta : Dictionary = collider.tile_set.get_meta("tile_meta")
		if tile_meta.has(id):
			tilemap_tile_meta = tile_meta[id]
	
	return collider