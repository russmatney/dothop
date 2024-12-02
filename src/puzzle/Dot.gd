@tool
extends Node2D
class_name DotHopDot

## vars #########################################################

@export var type: DHData.dotType
@export var square_size = 32 :
	set(v):
		square_size = v
		render()

var display_name = "dot"

var label
var color_rect
var area

signal dot_pressed

## Log.pp #########################################################

func data():
	return {name=display_name, node=str(self), global_pos=self.get_global_position()}

## ready #########################################################

func _ready():
	U.set_optional_nodes(self, {
		label="ObjectLabel", color_rect="ColorRect",
		area="Area2D"})

	if area == null:
		ensure_area()

	render()

func ensure_area():
	var rect = Rect2(Vector2.ONE * square_size / -2.0, Vector2.ONE * square_size)
	area = Reptile.to_area2D(null, rect)
	area.input_event.connect(func(_viewport, event, _shape_idx):
		if Trolls.is_tap(event) or Trolls.is_click(event):
			dot_pressed.emit()
		)
	add_child(area)

## set_initial_coord #########################################################

var current_coord: Vector2
func set_initial_coord(coord):
	current_coord = coord
	position = coord * square_size

func current_position():
	return current_coord * square_size

## render #########################################################

func render():
	if label != null:
		match type:
			DHData.dotType.Dot: display_name = "dot"
			DHData.dotType.Dotted: display_name = "dotted"
			DHData.dotType.Goal: display_name = "goal"

		label.text = "[center]%s[/center]" % display_name
		label.custom_minimum_size = Vector2.ONE * square_size

	if color_rect != null:
		color_rect.size = Vector2.ONE * square_size

		match type:
			DHData.dotType.Dot: color_rect.color = Color(1, 1, 0)
			DHData.dotType.Dotted: color_rect.color = Color(0, 1, 1)
			DHData.dotType.Goal: color_rect.color = Color(1, 0, 1)

## type changes #########################################################

func mark_goal():
	type = DHData.dotType.Goal
	render()

func mark_dotted():
	type = DHData.dotType.Dotted
	render()

func mark_undotted():
	type = DHData.dotType.Dot
	render()
