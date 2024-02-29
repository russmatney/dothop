@tool
extends Object
class_name DHData


enum dotType { Dot, Dotted, Goal}

static var puzzle_group = "dothop_puzzle"
static var reset_hold_t = 0.4

static func calc_stats(puzzle_sets):
	var total_puzzles = 0
	var puzzles_completed = 0
	var total_dots = 0
	var dots_hopped = 0

	for ps in puzzle_sets:
		for p in ps.get_puzzles():
			total_dots += p.dot_count()
			total_puzzles += 1
			if p.is_completed:
				puzzles_completed += 1
				dots_hopped += p.dot_count()

	return {
		total_dots=total_dots, dots_hopped=dots_hopped,
		total_puzzles=total_puzzles, puzzles_completed=puzzles_completed,
		}
