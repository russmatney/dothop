@tool
extends CanvasLayer

## vars ######################################################

@onready var puzzle_sets: Array[PuzzleSet] = Store.get_puzzle_sets()

@onready var puzzle_set_grid = $%PuzzleSetGrid
@onready var puzzles_grid = $%PuzzlesGrid

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

func on_puzzle_set_button_pressed(ps: PuzzleSet):
	Log.pr("puzzle_set button pressed", ps)

	select_puzzle_set(ps)

func select_puzzle_set(ps: PuzzleSet):
	U.remove_children(puzzles_grid)
	for p in ps.get_puzzles():
		# var bg_music = ps.get_theme().get_background_music()
		# var dot_texture = ps.get_theme().get_dot_icon()
		# var dotted_texture = ps.get_theme().get_dotted_icon()
		var player_texture = ps.get_theme().get_player_icon()
		var texture = TextureRect.new()
		texture.set_texture(player_texture)
		puzzles_grid.add_child(texture)
