@tool
extends CanvasLayer

## vars ######################################################

@onready var puzzle_sets: Array[PuzzleSet] = Store.get_puzzle_sets()

@onready var puzzle_set_grid = $%PuzzleSetGrid
@onready var puzzles_grid = $%PuzzlesGrid
@onready var current_puzzle_label = $%CurrentPuzzleLabel
@onready var current_puzzle_analysis_label = $%CurrentPuzzleAnalysisLabel

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

func on_puzzle_button_pressed(p):
	select_puzzle(p)

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

		texture.pressed.connect(on_puzzle_button_pressed.bind(p))

		puzzles_grid.add_child(texture)

func select_puzzle(p):
	Log.pr("puzzle selected", p)

	# TODO pretty print whatever this type is
	current_puzzle_label.text = str(p)
	# TODO print puzzle solver data here
	current_puzzle_analysis_label.text = str(p)
