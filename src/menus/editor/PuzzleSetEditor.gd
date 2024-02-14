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

		var button = Button.new()
		button.text = ps.get_display_name()
		button.pressed.connect(on_puzzle_set_button_pressed.bind(ps))
		puzzle_set_grid.add_child(button)

## on ######################################################

func on_puzzle_set_button_pressed(ps: PuzzleSet):
	# Log.pr("puzzle_set button pressed", ps)
	select_puzzle_set(ps)

func on_puzzle_button_pressed(ps: PuzzleSet, p):
	select_puzzle(ps, p)

## select ######################################################

func select_puzzle_set(ps: PuzzleSet):
	U.remove_children(puzzles_grid)
	for p in ps.get_puzzles():
		# var bg_music = ps.get_theme().get_background_music()
		var dot_texture = ps.get_theme().get_dot_icon()
		var dotted_texture = ps.get_theme().get_dotted_icon()
		var player_texture = ps.get_theme().get_player_icon()
		var texture = TextureButton.new()

		texture.set_texture_hover(player_texture)
		texture.set_texture_normal(dot_texture)
		texture.set_texture_disabled(dotted_texture)

		texture.pressed.connect(on_puzzle_button_pressed.bind(ps, p))

		puzzles_grid.add_child(texture)

func select_puzzle(ps: PuzzleSet, p):
	# TODO this feels like it should be a viewport, not a panel container
	U.remove_children(puzzle_container)

	Log.pr("puzzle selected", p)

	# TODO pretty print whatever this type is
	current_puzzle_label.text = str(p)
	# TODO print puzzle solver data here
	current_puzzle_analysis_label.text = str(p)

	if puzzle_node != null:
		puzzle_container.remove_child.call_deferred(puzzle_node)
		puzzle_node.queue_free()
		# is this a race case? or is it impossible?
		await puzzle_node.tree_exited

	var theme = ps.get_theme()

	puzzle_node = DotHopPuzzle.build_puzzle_node({
		puzzle_scene=theme.get_puzzle_scene(),
		game_def=ps.get_game_def(),
		puzzle_num=p.get("idx"),
		})
	# TODO simply by passing theme in above?
	puzzle_node.player_scenes = theme.get_player_scenes()
	puzzle_node.dot_scenes = theme.get_dot_scenes()
	puzzle_node.goal_scenes = theme.get_goal_scenes()
	# puzzle_node.hide_background = true

	puzzle_container.add_child(puzzle_node)
