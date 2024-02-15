extends Camera2D

func _ready():
	Log.pr("dh cam ready")

var node_rect
var zoom_min = 0.5
var zoom_max = 5.0

# var zoom_margin = Vector4(-64, -64, 64, 64)
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

	# rect = rect.grow_individual(zoom_margin.x, zoom_margin.y, zoom_margin.z, zoom_margin.w)

	Log.pr("new node_rect", rect)
	node_rect = rect
	# queue_redraw()

	rect = rect.grow(base_margin)

	var screen_size: Vector2 = get_viewport_rect().size
	Log.pr("screen size", screen_size)
	if rect.size.x > rect.size.y * screen_size.aspect():
		Log.pr("larger x", screen_size.x / rect.size.x)
		zoom = clamp(screen_size.x / rect.size.x, zoom_min, zoom_max) * Vector2.ONE
	else:
		Log.pr("larger y", screen_size.y / rect.size.y)
		zoom = clamp(screen_size.y / rect.size.y, zoom_min, zoom_max) * Vector2.ONE
	Log.pr("clamped zoom", zoom)

	global_position = rect.get_center()


# func _draw():
# 	if node_rect:
# 		Log.pr("drawing node rect", node_rect)
# 		draw_rect(node_rect, Color("3ab99a"), false, 2)

# 		draw_circle(node_rect.get_center(), 5, Color("3ab99a"))
# 	else:
# 		Log.pr("no node rect!")
