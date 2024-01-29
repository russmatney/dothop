@tool
extends Event
class_name PuzzleSetCompleted

func get_puzzle_set() -> PuzzleSet:
	return get_resource("puzzle_set")

func data():
	var d = super.data()
	d.merge({puzzle_set=get_puzzle_set(),})
	return d
