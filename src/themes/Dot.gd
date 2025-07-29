@tool
extends Node2D
class_name DotHopDot

## vars #########################################################

@export var type: DHData.dotType
@export var square_size: int = 32 :
	set(v):
		square_size = v
		render()

@export var dot_color: Color = Color.PERU
@export var dotted_color: Color = Color.ALICE_BLUE
@export var goal_color: Color = Color.CRIMSON

var display_name: String = "dot"

var label: RichTextLabel
var color_rect: ColorRect
var area: Area2D
var current_coord: Vector2

var anim: AnimatedSprite2D

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
		area="Area2D",
		anim="AnimatedSprite2D"})

	if area == null:
		ensure_area()

	render()

	match type:
		DHData.dotType.Dot: mark_undotted()
		DHData.dotType.Dotted: mark_dotted()
		DHData.dotType.Goal: mark_goal()

	# wait a bit to start animating
	if anim:
		var wait_for := 1.0 + randfn(1.0, 1.0)
		U.call_in(self, Anim.float_a_bit.bind(self, position), wait_for)

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
		label.custom_minimum_size = Vector2.ONE * square_size
	if color_rect != null:
		color_rect.size = Vector2.ONE * square_size

## type changes #########################################################

func mark_goal() -> void:
	type = DHData.dotType.Goal
	if label != null:
		label.text = "[center]%s[/center]" % "goal"
	if color_rect != null:
		color_rect.color = goal_color
	if anim:
		set_z_index(0)
		anim.play("goal")
		U.set_random_frame(anim)
	render()

func mark_dotted() -> void:
	type = DHData.dotType.Dotted
	if label != null:
		label.text = "[center]%s[/center]" % "dotted"
	if color_rect != null:
		color_rect.color = dotted_color
	if anim:
		set_z_index(0)
		# TODO wait for player-move-finished signal
		await get_tree().create_timer(0.4).timeout
		if type == DHData.dotType.Dotted: # if we're still dotted
			anim.play("dotted")
			U.set_random_frame(anim)
	render()

func mark_undotted() -> void:
	type = DHData.dotType.Dot
	if label != null:
		label.text = "[center]%s[/center]" % "dot"
	if color_rect != null:
		color_rect.color = dot_color
	if anim:
		set_z_index(1)
		anim.play("dot")
		U.set_random_frame(anim)
	render()

## state changes #########################################################

var tween: Tween

func show_possible_next_move() -> void:
	tween = Anim.scale_up_down_up(self, 0.9)
	tween.set_loops()

func show_possible_undo() -> void:
	tween = Anim.scale_down_up(self, 1.9)
	tween.set_loops()

func remove_possible_next_move() -> void:
	if tween:
		tween.kill()
	scale = Vector2.ONE
