extends Node2D

class Line:
	var start: Vector2
	var end: Vector2

	func to_pretty() -> Variant:
		return [start, end]

	func _init(s: Vector2) -> void:
		start = s

	func finish(e: Vector2) -> void:
		end = e

var lines: Array[Line] = []
var current_line: Line

var camera: Camera2D

func to_pretty() -> Variant:
	return [lines]

func _ready() -> void:
	camera = get_viewport().get_camera_2d()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mbe: InputEventMouseButton = event as InputEventMouseButton
		if mbe.button_index == MOUSE_BUTTON_RIGHT and mbe.pressed:
			var pos := camera.get_global_mouse_position()
			current_line = Line.new(pos)
			Log.pr("started a line", current_line)

	if event is InputEventMouseButton:
		var mbe: InputEventMouseButton = event as InputEventMouseButton
		if mbe.button_index == MOUSE_BUTTON_RIGHT and not mbe.pressed:
			# finished drawing
			if current_line == null:
				return
			var pos := camera.get_global_mouse_position()
			current_line.finish(pos)
			Log.pr("added a line", current_line)
			lines.append(current_line)
			queue_redraw()

	if Trolls.is_restart(event):
		lines.clear()
		queue_redraw()

func _draw() -> void:
	for l in lines:
		Log.pr("drew a line", l)
		draw_line(l.start, l.end, Color.AQUAMARINE, 8)
