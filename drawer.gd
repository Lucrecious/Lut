extends Node2D

class_name Drawer

var draw_queue : Array = []

class Line extends Reference:
	var p1 : Vector2
	var p2 : Vector2
	var color : Color
	var thickness : float
	func _init(p1 : Vector2, p2 : Vector2, color : Color, thickness : float):
		self.p1 = p1
		self.p2 = p2
		self.color = color
		self.thickness = thickness

class Rect extends Reference:
	var rect : Rect2
	var color : Color
	var filled : bool
	func _init(rect, color, filled):
		self.rect = rect
		self.color = color
		self.filled = filled

func drawpath(
		map : TileMap,
		path : Array,
		color: Color = Color(1, 0, 0, 1),
		thickness : float = 1.0) -> void:
	for i in range(path.size() - 1):
		var p1 : Vector2 = Vector2(path[i].x, path[i].y)
		var p2 : Vector2 = Vector2(path[i + 1].x, path[i + 1].y)

		var middle : Vector2 = Vector2(float(Game.BLOCK_SIZE) / 2.0, float(Game.BLOCK_SIZE) / 2.0)

		var wp1 : Vector2 = map.map_to_world(p1) + middle
		var wp2 : Vector2 = map.map_to_world(p2) + middle

		drawrect(wp2.x - 5, wp2.y - 5, 10, 10, color, thickness)
		drawline(wp1, wp2, color, thickness)

func drawline(
		p1 : Vector2,
		p2 : Vector2,
		color : Color = Color(1, 0, 0, 1),
		thickness : float = 1.0) -> void:
	draw_queue.push_front(Line.new(p1, p2, color, thickness))

func drawrect(
		x : float,
		y : float,
		w : float,
		h : float,
		color : Color = Color(1, 0, 0, 1),
		filled : bool = true) -> void:
	draw_queue.push_front(Rect.new(Rect2(x, y, w, h), color, filled))

#warning-ignore: unused_argument
func _process(delta : float) -> void:
	update()

func _draw() -> void:
	while draw_queue.size() > 0:
		#warning-ignore: void_assignment
		var drawable : Reference = draw_queue.pop_front()
		if drawable is Line:
			draw_line(
				drawable.p1,
				drawable.p2,
				drawable.color,
				drawable.thickness)
		elif drawable is Rect:
			draw_rect(drawable.rect, drawable.color, drawable.filled)









