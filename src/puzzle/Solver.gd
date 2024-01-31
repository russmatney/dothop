extends Object
class_name Solver

## vars ####################################

var puzzle: DotHopPuzzle
var move_tree := {}

## init ####################################

func _init(puzzle_node: DotHopPuzzle):
	puzzle = puzzle_node

## solve ####################################

var all_dirs = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]

func try_moves(current_move_dict, last_move):
	var any_moves = false
	for dir in all_dirs:
		if last_move and dir == -1 * last_move:
			continue # skip 'undos'

		var did_step = step(dir)
		if did_step:
			any_moves = true

			current_move_dict[dir] = try_moves({}, dir)

			if not puzzle.state.win:
				# undo the move
				puzzle.move(dir * -1)

	if any_moves:
		return current_move_dict
	else:
		# return true if the puzzle has been won!
		return puzzle.state.win

func step(direction):
	return puzzle.move(direction)

func build_move_tree():
	return try_moves({}, null)
