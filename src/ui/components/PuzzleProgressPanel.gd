extends Control
class_name PuzzleProgressPanel

## vars ############################################################

@onready var puzzle_list: GridContainer = $%PuzzleList
@onready var panel_container: PanelContainer = $%PuzzlePanelContainer
@onready var world_icon: TextureRect = $%PuzzleSetIcon
@onready var animated_container: AnimatedVBoxContainer = $%AnimatedVBoxContainer
var world: PuzzleWorld
var start_puzzle_num: int
var end_puzzle_num: int

@export var icon_size: float = 64.0
@export var grid_columns: int = 4

signal rendered

## ready ############################################################

func _ready() -> void:
	animated_container.set_custom_minimum_size(Vector2.ZERO)
	if not icon_size:
		icon_size = 64
	if not grid_columns:
		grid_columns = 4
	world_icon.set_custom_minimum_size(icon_size * Vector2.ONE)
	world_icon.set_size(icon_size * Vector2.ONE)
	world_icon.set_pivot_offset(world_icon.size / 2)
	animated_container.child_size = icon_size * Vector2.ONE
	puzzle_list.set_columns(grid_columns)

	panel_container.minimum_size_changed.connect(func() -> void:
		set_custom_minimum_size(panel_container.get_size())
		set_size(panel_container.get_size()))

## disable animations ##################################################

func disable_resize_animation() -> void:
	# apparently called before _ready()?
	var cont: AnimatedVBoxContainer = get_node("%AnimatedVBoxContainer")
	cont.disable_animations = true

## build puzzle list ############################################################

func render(opts: Dictionary) -> void:
	animated_container.set_custom_minimum_size(Vector2.ZERO)
	world = opts.get("world")
	start_puzzle_num = opts.get("start_puzzle_num", 0)
	end_puzzle_num = opts.get("end_puzzle_num", start_puzzle_num)
	if not world:
		Log.warn("No puzzle set found in PuzzleProgressPanel")
		return

	var ps_theme: PuzzleTheme = world.get_theme()

	var start_puzzle_icon: TextureRect
	var end_puzzle_icon: TextureRect

	U.remove_children(puzzle_list)
	for i: int in range(len(world.get_puzzles())):
		var icon: TextureRect = TextureRect.new()
		icon.set_custom_minimum_size(icon_size * Vector2.ONE)
		if world.completed_puzzle(i):
			icon.set_texture(ps_theme.get_dot_icon())
			icon.set_focus_mode(Control.FOCUS_ALL)
		elif world.skipped_puzzle(i):
			# TODO differentiate skipped puzzle!
			icon.set_texture(ps_theme.get_dot_icon()) # TODO use skipped icon
			icon.set_focus_mode(Control.FOCUS_ALL)
			icon.set_modulate(Color(0.8, 0.8, 0.8, 0.8))
		elif world.can_play_puzzle(i):
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

	world_icon.set_texture(ps_theme.get_player_icon())
	world_icon.modulate.a = 0.0

	if start_puzzle_icon and end_puzzle_icon:
		# ugh, this hard-coded time is gross....
		# needs to let the resizing and toasting run first
		U.call_in(self, func() -> void: move_puzzle_cursor(end_puzzle_icon, {from=start_puzzle_icon}),
			0.8)

	rendered.emit()

func move_puzzle_cursor(icon: TextureRect, opts: Dictionary = {}) -> void:
	if opts.get("no_show", false):
		world_icon.modulate.a = 0.0
		world_icon.global_position = icon.global_position
		return

	if opts.get("from", false):
		world_icon.global_position = opts.from.global_position

	var time: float = 0.4
	var t: Tween = create_tween()
	t.tween_property(world_icon, "modulate:a", 1.0, time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(world_icon, "global_position", icon.global_position, time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var scale_tween: Tween = create_tween()
	scale_tween.tween_property(world_icon, "scale", 1.3*Vector2.ONE, time/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(world_icon, "scale", 0.8*Vector2.ONE, time/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(world_icon, "scale", 1.0*Vector2.ONE, time/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
