@tool
extends Jumbotron
class_name PuzzleComplete

## vars ############################################################

@onready var puzzle_progress_panel: PuzzleProgressPanel = $%PuzzleProgressPanel
var puzzle_set: PuzzleSet
var start_puzzle_num: int
var end_puzzle_num: int

## ready ############################################################

func _ready() -> void:
	render()

## build puzzle list ############################################################

func render() -> void:
	if not puzzle_set:
		# puzzle_set = Store.get_puzzle_sets()[0]
		Log.warn("No puzzle set found on PuzzleComplete scene")
		return

	puzzle_progress_panel.render({
		puzzle_set=puzzle_set,
		start_puzzle_num=start_puzzle_num,
		end_puzzle_num=end_puzzle_num,
		})
