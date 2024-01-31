extends Object
class_name Solver

## vars ####################################

const WIN = "WIN"
const STUCK = "STUCK"

var puzzle: DotHopPuzzle

## init ####################################

func _init(puzzle_node: DotHopPuzzle):
	puzzle = puzzle_node

## solve ####################################

var all_dirs = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]

func collect_move_tree(current_move_dict={}, last_move=null):
	var any_moves = false
	for dir in all_dirs:
		if last_move and dir == -1 * last_move:
			continue # skip 'undos'

		var did_step = puzzle.move(dir)
		if did_step:
			any_moves = true
			current_move_dict[dir] = collect_move_tree({}, dir)
			puzzle.move(-1 * dir) # undo

	if any_moves:
		# we made a move, return this move-tree
		return current_move_dict
	else:
		if puzzle.state.win:
			return WIN
		else:
			return STUCK

func collect_paths(move_tree, current_path=[], paths=[]):
	if not move_tree is Dictionary:
		# this is a test-only edge case, but if we can't make moves from the start...
		var new_path = current_path.duplicate()
		new_path.append(move_tree)
		paths.append(new_path)
		return paths

	for dir in move_tree.keys():
		var new_path = current_path.duplicate() # new path for each move
		new_path.append(dir)

		var node = move_tree[dir]
		if node is Dictionary:
			collect_paths(node, new_path, paths)
		elif node == WIN or node == STUCK:
			new_path.append(node)
			paths.append(new_path)

	return paths

func analyze():
	var move_tree = collect_move_tree()
	var paths = collect_paths(move_tree)

	var winning_paths = paths.filter(func(p): return p[-1] == WIN)
	var solvable = len(winning_paths) > 0
	var dot_count = 0
	if solvable:
		dot_count = len(winning_paths[0])

	var width = puzzle.level_def.width
	var height = puzzle.level_def.height

	return {
		move_tree=move_tree,
		paths=paths,
		solvable=solvable,
		width=width,
		height=height,
		dot_count=dot_count,
		path_count=len(paths),
		winning_path_count=len(winning_paths),
		stuck_path_count=len(paths) - len(winning_paths),
		}
