@tool
extends Object
class_name DHData


enum dotType { Dot, Dotted, Goal}

static var puzzle_group: StringName = "dothop_puzzle"
static var reset_hold_t: float = 0.4

static func calc_stats(puzzle_sets: Array[PuzzleSet]) -> Dictionary:
	var total_puzzles: int = 0
	var puzzles_completed: int = 0
	var total_dots: int = 0
	var dots_hopped: int = 0

	for ps: PuzzleSet in puzzle_sets:
		for p: PuzzleDef in ps.get_puzzles():
			total_dots += p.dot_count()
			total_puzzles += 1
			if p.is_completed:
				puzzles_completed += 1
				dots_hopped += p.dot_count()

	return {
		total_dots=total_dots, dots_hopped=dots_hopped,
		total_puzzles=total_puzzles, puzzles_completed=puzzles_completed,
		}
