@tool
extends Node2D
class_name DotHopDot

## vars #########################################################

@export var type: DHData.dotType
@export var square_size: int = 32 :
	set(v):
		square_size = v
		render()

var display_name: String = "dot"

var label: RichTextLabel
var color_rect: ColorRect
var area: Area2D
var current_coord: Vector2

signal dot_pressed
signal mouse_entered
signal mouse_dragged

## Log.pp #########################################################

func data() -> Variant:
	return {name=display_name, node=str(self), global_pos=self.get_global_position()}

## ready #########################################################

func _enter_tree() -> void:
	add_to_group("dot", true)

func _ready() -> void:
	U.set_optional_nodes(self, {
		label="ObjectLabel", color_rect="ColorRect",
		area="Area2D"})

	if area == null:
		ensure_area()

	render()

func ensure_area() -> void:
	var rect: Rect2 = Rect2(Vector2.ONE * square_size / -2.0, Vector2.ONE * square_size)
	area = Reptile.to_area2D(null, rect)
	area.input_event.connect(func(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
		if Trolls.is_tap(event) or Trolls.is_click(event):
			dot_pressed.emit()
		if Trolls.is_mouse_drag(event):
			mouse_dragged.emit())
	area.mouse_entered.connect(func() -> void: mouse_entered.emit())
	add_child(area)
	area.ready.connect(func() -> void: area.set_owner(area.get_parent()))

## set_initial_coord #########################################################

func set_initial_coord(coord: Vector2) -> void:
	current_coord = coord
	position = coord * square_size

func current_position() -> Vector2:
	return current_coord * square_size

## render #########################################################

func render() -> void:
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

func mark_goal() -> void:
	type = DHData.dotType.Goal
	render()

func mark_dotted() -> void:
	type = DHData.dotType.Dotted
	render()

func mark_undotted() -> void:
	type = DHData.dotType.Dot
	render()

## state changes #########################################################

func show_possible_next_move() -> void:
	pass

func show_possible_undo() -> void:
	pass

func remove_possible_next_move() -> void:
	pass
