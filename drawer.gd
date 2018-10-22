extends CanvasItem

var draw_queue = []

class Line extends Reference:
	var p1
	var p2
	var color
	var thickness
	func _init(p1, p2, color, thickness):
		self.p1 = p1
		self.p2 = p2
		self.color = color
		self.thickness = thickness

class Rect extends Reference:
	var rect
	var color
	var filled
	func _init(rect, color, filled):
		self.rect = rect
		self.color = color
		self.filled = filled
	
var Tile = Game.NavigationMaps.Tile
func drawpath(nav_map, path, color=Color(1, 0, 0, 1), thickness=1.0):
	for i in range(path.size() - 1):
		var p1 = Vector2(Tile.x(path[i]), Tile.y(path[i]))
		var p2 = Vector2(Tile.x(path[i + 1]), Tile.y(path[i + 1]))
		
		var middle = Vector2(Game.BLOCK_SIZE / 2, Game.BLOCK_SIZE / 2)
		
		var wp1 = nav_map.world_pos(p1) + middle
		var wp2 = nav_map.world_pos(p2) + middle
		
		drawrect(wp2.x - 5, wp2.y - 5, 10, 10, color, thickness)
		drawline(wp1, wp2, color, thickness)

func drawline(p1, p2, color=Color(1, 0, 0, 1), thickness=1.0):
	draw_queue.push_front(Line.new(p1, p2, color, thickness))

func drawrect(x, y, w, h, color=Color(1, 0, 0, 1), filled=true):
	draw_queue.push_front(Rect.new(Rect2(x, y, w, h), color, filled))

func _process(delta):
	update()

func _draw():
	while draw_queue.size() > 0:
		var drawable = draw_queue.pop_front()
		if drawable is Line:
			draw_line(
				drawable.p1,
				drawable.p2,
				drawable.color,
				drawable.thickness)
		elif drawable is Rect:
			draw_rect(drawable.rect, drawable.color, drawable.filled)









