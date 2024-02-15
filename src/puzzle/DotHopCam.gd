extends Camera2D

var node_rect
var zoom_min = 0.5
var zoom_max = 5.0
var base_margin = 64

func center_on_nodes(nodes):
	if len(nodes) == 0:
		return

	var rect = Rect2(nodes[0].get_global_position(), Vector2.ZERO)
	for node in nodes:
		if "square_size" in node:
			# scale might also be a factor
			rect = rect.expand(node.get_global_position() + node.square_size * Vector2.ONE * 1.0)
			rect = rect.expand(node.get_global_position() - node.square_size * Vector2.ONE * 0.5)
		else:
			rect = rect.expand(node.get_global_position())

	node_rect = rect

	rect = rect.grow(base_margin)

	var screen_size: Vector2 = get_viewport_rect().size
	if rect.size.x > rect.size.y * screen_size.aspect():
		zoom = clamp(screen_size.x / rect.size.x, zoom_min, zoom_max) * Vector2.ONE
	else:
		zoom = clamp(screen_size.y / rect.size.y, zoom_min, zoom_max) * Vector2.ONE

	global_position = rect.get_center()
