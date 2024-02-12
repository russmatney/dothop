@tool
extends Jumbotron

## vars ############################################################

@onready var puzzle_list = $%PuzzleList
@onready var puzzle_set_icon = $%PuzzleSetIcon
var puzzle_set: PuzzleSet
var puzzle_num: int

## ready ############################################################

func _ready():
	render()

## build puzzle list ############################################################

func render():
	if not puzzle_set:
		Log.warn("No puzzle set found on PuzzleComplete scene")
		return
	var theme = puzzle_set.get_theme()

	var completed_puzzle_icon
	var next_puzzle_icon

	U.remove_children(puzzle_list)
	for i in range(len(puzzle_set.get_puzzles())):
		var icon = TextureRect.new()
		icon.set_custom_minimum_size(64.0 * Vector2.ONE)
		if puzzle_set.completed_puzzle(i):
			icon.set_texture(theme.get_dotted_icon())
			icon.set_focus_mode(Control.FOCUS_ALL)
		elif puzzle_set.can_play_puzzle(i):
			icon.set_focus_mode(Control.FOCUS_ALL)
			icon.set_texture(theme.get_dot_icon())
		else:
			icon.set_texture(theme.get_dot_icon())
			icon.set_modulate(Color(0.5, 0.5, 0.5, 0.5))

		if i == puzzle_num:
			completed_puzzle_icon = icon
		elif i == puzzle_num + 1:
			next_puzzle_icon = icon

		puzzle_list.add_child(icon)

	puzzle_set_icon.set_texture(theme.get_player_icon())
	puzzle_set_icon.modulate.a = 0.0

	if completed_puzzle_icon:
		U.call_in(0.5, self, func(): move_level_cursor(next_puzzle_icon, {from=completed_puzzle_icon}))

func move_level_cursor(icon, opts={}):
	if opts.get("no_show", false):
		puzzle_set_icon.modulate.a = 0.0
		puzzle_set_icon.position = icon.global_position
		return

	if opts.get("from", false):
		puzzle_set_icon.position = opts.from.global_position

	var time = 0.4
	var t = create_tween()
	t.tween_property(puzzle_set_icon, "modulate:a", 1.0, time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(puzzle_set_icon, "position", icon.global_position, time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var scale_tween = create_tween()
	scale_tween.tween_property(puzzle_set_icon, "scale", 1.3*Vector2.ONE, time/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(puzzle_set_icon, "scale", 0.8*Vector2.ONE, time/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(puzzle_set_icon, "scale", 1.0*Vector2.ONE, time/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
