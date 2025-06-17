extends Object
class_name PuzzleAnalysis

## vars ####################################

const WIN: String = "WIN"
const STUCK_GOAL: String = "STUCK_GOAL"
const STUCK_DOT: String = "STUCK_DOT"

var puzzle_node: DotHopPuzzle

## init ####################################

func _init(node: DotHopPuzzle) -> void:
	puzzle_node = node

## collect_move_tree ####################################

const all_dirs: Array[Vector2] = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]

func collect_move_tree(current_move_dict: Dictionary = {}, last_move: Variant = null) -> Variant:
	var any_moves: bool = false
	for dir: Vector2 in all_dirs:
		if last_move is Vector2 and dir == -1 * last_move:
			continue # skip 'undos'

		var move_res: DotHopPuzzle.MoveResult = puzzle_node.move(dir)
		if move_res == DotHopPuzzle.MoveResult.moved:
			any_moves = true
			current_move_dict[dir] = collect_move_tree({}, dir)
			puzzle_node.move(-1 * dir) # undo

	if any_moves:
		# we made a move, return this move-tree
		return current_move_dict
	else:
		if puzzle_node.state.win:
			return WIN
		elif puzzle_node.state.all_players_at_goal():
			return STUCK_GOAL
		else:
			return STUCK_DOT

## collect_paths ####################################

func collect_paths(_move_tree: Variant, current_path: Array = [], _paths: Array = []) -> Array:
	if not _move_tree is Dictionary:
		# this is a test-only edge case, but if we can't make moves from the start...
		var new_path: Array = current_path.duplicate()
		new_path.append(_move_tree)
		_paths.append(new_path)
		return _paths

	for dir: Vector2 in (_move_tree as Dictionary).keys():
		var new_path: Array = current_path.duplicate() # new path for each move
		new_path.append(dir)

		var node: Variant = _move_tree[dir]
		if node is Dictionary:
			collect_paths(node, new_path, _paths)
		elif node == WIN or node == STUCK_DOT or node == STUCK_GOAL:
			new_path.append(node)
			_paths.append(new_path)

	return _paths

## analyze ####################################

var move_tree: Variant #: Dictionary | String
var paths: Array

var winning_paths: Array
var stuck_dot_paths: Array
var stuck_goal_paths: Array

var solvable: bool
var width: int = 0
var height: int = 0

var dot_count: int = 0

var path_count : int
var winning_path_count : int
var stuck_path_count : int
var stuck_dot_path_count : int
var stuck_goal_path_count : int

func analyze() -> PuzzleAnalysis:
	move_tree = collect_move_tree()
	paths = collect_paths(move_tree)

	winning_paths = paths.filter(func(p: Array) -> bool: return p[-1] == WIN)
	stuck_dot_paths = paths.filter(func(p: Array) -> bool: return p[-1] == STUCK_DOT)
	stuck_goal_paths = paths.filter(func(p: Array) -> bool: return p[-1] == STUCK_GOAL)

	path_count = len(paths)
	winning_path_count = len(winning_paths)
	stuck_path_count = len(paths) - len(winning_paths)
	stuck_dot_path_count = len(stuck_dot_paths)
	stuck_goal_path_count = len(stuck_goal_paths)

	solvable = len(winning_paths) > 0
	if solvable:
		dot_count = len(winning_paths[0])

	width = puzzle_node.puzzle_def.width
	height = puzzle_node.puzzle_def.height

	return self
