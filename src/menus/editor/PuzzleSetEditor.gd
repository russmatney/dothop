@tool
extends CanvasLayer

## vars ######################################################

@onready var puzzle_sets: Array[PuzzleSet] = Store.get_puzzle_sets()

@onready var puzzle_set_grid = $%PuzzleSetGrid
@onready var puzzles_grid = $%PuzzlesGrid
@onready var current_puzzle_label = $%CurrentPuzzleLabel
@onready var current_puzzle_analysis_label = $%CurrentPuzzleAnalysisLabel
@onready var puzzle_container = $%PuzzleContainer
var puzzle_node

## ready ######################################################

func _ready():
	render()
	if len(puzzle_sets) > 0:
		select_puzzle_set(puzzle_sets[0])

## render ######################################################

func render():
	U.remove_children(puzzle_set_grid)
	for ps in puzzle_sets:
		Log.pr("rendering puzzle set", ps.get_display_name())

		var dot_texture = ps.get_theme().get_dot_icon()
		var dotted_texture = ps.get_theme().get_dotted_icon()
		var player_texture = ps.get_theme().get_player_icon()
		var button = TextureButton.new()
		button.custom_minimum_size = Vector2(64, 64)
		button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT

		button.set_texture_normal(player_texture)
		button.set_texture_hover(dot_texture)
		button.set_texture_disabled(dotted_texture)

		# button.text = ps.get_display_name()
		button.pressed.connect(on_puzzle_set_button_pressed.bind(ps))
		puzzle_set_grid.add_child(button)

## on ######################################################

func on_puzzle_set_button_pressed(ps: PuzzleSet):
	# Log.pr("puzzle_set button pressed", ps)
	select_puzzle_set(ps)

func on_puzzle_button_pressed(ps: PuzzleSet, p: PuzzleDef):
	select_puzzle(ps, p)

## select ######################################################

func select_puzzle_set(ps: PuzzleSet):
	ps.get_analyzed_game_def() # trigger solver analysis for whole puzzle set
	U.remove_children(puzzles_grid)
	var first
	for puzzle_def in ps.get_puzzles():
		if not first:
			first = puzzle_def
		# var bg_music = ps.get_theme().get_background_music()
		var dot_texture = ps.get_theme().get_dot_icon()
		var dotted_texture = ps.get_theme().get_dotted_icon()
		var player_texture = ps.get_theme().get_player_icon()
		var texture = TextureButton.new()
		texture.custom_minimum_size = Vector2(96, 96)
		texture.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT

		texture.set_texture_hover(player_texture)
		texture.set_texture_normal(dot_texture)
		texture.set_texture_disabled(dotted_texture)

		texture.pressed.connect(on_puzzle_button_pressed.bind(ps, puzzle_def))

		puzzles_grid.add_child(texture)
	if first:
		select_puzzle(ps, first)

func select_puzzle(ps: PuzzleSet, puzzle_def: PuzzleDef):
	Log.pr("Puzzle selected", puzzle_def)
	var w = puzzle_def.width
	var h = puzzle_def.height
	var msg = puzzle_def.message
	var idx = puzzle_def.idx # not necessarily the order, which puzzle-sets can overwrite
	var analysis = puzzle_def.analysis

	current_puzzle_label.text = "[center]%s # %s" % [ps.get_display_name(), idx + 1]
	var detail = "w: %s, h: %s" % [w, h]
	if msg:
		detail += " msg: %s" % msg

	if analysis:
		detail += "\ndots: [color=dark_blue]%s[/color]" % analysis.get("dot_count")
		detail += " paths: [color=forest_green]%s win[/color]/[color=crimson]%s stuck_dot[/color]/[color=crimson]%s stuck_goal[/color]/[color=peru]%s all[/color]" % [
			analysis.get("winning_path_count"),
			analysis.get("stuck_dot_path_count"),
			analysis.get("stuck_goal_path_count"),
			analysis.get("path_count"),
			]

	current_puzzle_analysis_label.text = detail

	if puzzle_node != null:
		var outro_complete = Anim.puzzle_animate_outro_to_point(puzzle_node)
		await outro_complete
		puzzle_node.queue_free()

	var theme = ps.get_theme()
	puzzle_node = DotHopPuzzle.build_puzzle_node({
		game_def=ps.get_game_def(),
		puzzle_theme=theme,
		puzzle_num=puzzle_def.idx,
		})
	puzzle_node.ready.connect(func(): Anim.puzzle_animate_intro_from_point(puzzle_node))

	puzzle_container.add_child(puzzle_node)
