@tool
extends Control

## vars ############################################################

@onready var puzzle_list = $%PuzzleList
@onready var panel_container = $%PuzzlePanelContainer
@onready var puzzle_set_icon = $%PuzzleSetIcon
@onready var animated_container = $%AnimatedVBoxContainer
var puzzle_set: PuzzleSet
var start_puzzle_num: int
var end_puzzle_num: int

signal rendered

## ready ############################################################

func _ready():
	if not Engine.is_editor_hint():
		panel_container.minimum_size_changed.connect(func():
			set_custom_minimum_size(panel_container.get_size())
			set_size(panel_container.get_size()))

	if Engine.is_editor_hint():
		render({puzzle_set=Store.get_puzzle_sets()[0]})

## disable animations ##################################################

func disable_resize_animation():
	var cont = get_node("%AnimatedVBoxContainer")
	cont.disable_animations = true

## build puzzle list ############################################################

func render(opts):
	puzzle_set = opts.get("puzzle_set")
	start_puzzle_num = opts.get("start_puzzle_num", 0)
	end_puzzle_num = opts.get("end_puzzle_num", start_puzzle_num)
	if not puzzle_set:
		Log.warn("No puzzle set found in PuzzleProgressPanel")
		return

	var ps_theme = puzzle_set.get_theme()

	var start_puzzle_icon
	var end_puzzle_icon

	U.remove_children(puzzle_list)
	for i in range(len(puzzle_set.get_puzzles())):
		var icon = TextureRect.new()
		icon.set_custom_minimum_size(64.0 * Vector2.ONE)
		if puzzle_set.completed_puzzle(i):
			icon.set_texture(ps_theme.get_dot_icon())
			icon.set_focus_mode(Control.FOCUS_ALL)
		elif puzzle_set.can_play_puzzle(i):
			icon.set_focus_mode(Control.FOCUS_ALL)
			icon.set_texture(ps_theme.get_goal_icon())
		else:
			icon.set_texture(ps_theme.get_dotted_icon())
			icon.set_modulate(Color(0.5, 0.5, 0.5, 0.5))

		# TODO collect each step?
		if i == start_puzzle_num:
			start_puzzle_icon = icon
		if i == end_puzzle_num:
			end_puzzle_icon = icon

		puzzle_list.add_child(icon)

	puzzle_set_icon.set_texture(ps_theme.get_player_icon())
	puzzle_set_icon.modulate.a = 0.0

	if start_puzzle_icon and end_puzzle_icon:
		# ugh, this hard-coded time is gross....
		# needs to let the resizing and toasting run first
		U.call_in(0.8, self, func(): move_puzzle_cursor(end_puzzle_icon, {from=start_puzzle_icon}))

	rendered.emit()

func move_puzzle_cursor(icon, opts={}):
	if opts.get("no_show", false):
		puzzle_set_icon.modulate.a = 0.0
		puzzle_set_icon.global_position = icon.global_position
		return

	if opts.get("from", false):
		puzzle_set_icon.global_position = opts.from.global_position

	var time = 0.4
	var t = create_tween()
	t.tween_property(puzzle_set_icon, "modulate:a", 1.0, time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(puzzle_set_icon, "global_position", icon.global_position, time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var scale_tween = create_tween()
	scale_tween.tween_property(puzzle_set_icon, "scale", 1.3*Vector2.ONE, time/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(puzzle_set_icon, "scale", 0.8*Vector2.ONE, time/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(puzzle_set_icon, "scale", 1.0*Vector2.ONE, time/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
