@tool
extends Jumbotron

## vars ############################################################

@onready var puzzle_progress_panel = $%PuzzleProgressPanel
var puzzle_set: PuzzleSet
var start_puzzle_num: int
var end_puzzle_num: int

## ready ############################################################

func _ready():
	render()

## build puzzle list ############################################################

func render():
	if not puzzle_set:
		# puzzle_set = Store.get_puzzle_sets()[0]
		Log.warn("No puzzle set found on PuzzleComplete scene")
		return

	puzzle_progress_panel.render({
		puzzle_set=puzzle_set,
		start_puzzle_num=start_puzzle_num,
		end_puzzle_num=end_puzzle_num,
		})
