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

func to_pretty() -> Variant:
	return [lines]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mbe: InputEventMouseButton = event as InputEventMouseButton
		if mbe.button_index == MOUSE_BUTTON_RIGHT and mbe.pressed:
			current_line = Line.new(mbe.position)

	if event is InputEventMouseButton:
		var mbe: InputEventMouseButton = event as InputEventMouseButton
		if mbe.button_index == MOUSE_BUTTON_RIGHT and not mbe.pressed:
			# finished drawing
			if current_line == null:
				return
			current_line.finish(mbe.position)
			lines.append(current_line)
			queue_redraw()

	if Trolls.is_restart(event):
		lines.clear()
		queue_redraw()

func _draw() -> void:
	for l in lines:
		draw_line(l.start, l.end, Color.PERU, 8)
