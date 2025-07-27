extends Resource
class_name PuzzleAnalysis


class MovePath:
	extends Resource
	enum Result {INCOMPLETE = 0,WIN = 1, STUCK_GOAL = 2, STUCK_DOT = 3}

	var moves: Array[Vector2]
	var result: Result = Result.INCOMPLETE
	var choices: int = 0

	func _init(mvs: Array[Vector2]) -> void:
		moves = mvs

	func to_pretty() -> Variant:
		return {moves=len(moves), choices=choices, result=result}

	func add_step(mv: Vector2) -> void:
		moves.append(mv)
	func add_choice() -> void:
		choices += 1

	static func is_end_result(x: Variant) -> bool:
		return x in [Result.WIN, Result.STUCK_GOAL, Result.STUCK_DOT]
	func mark_result(res: Result) -> void:
		result = res

	func create_branch() -> MovePath:
		# ermagerd don't forget to dupe the array
		var new_mp := MovePath.new(moves.duplicate())
		new_mp.result = result
		new_mp.choices = choices
		return new_mp

	func is_winning() -> bool:
		return result == Result.WIN
	func is_stuck_dot() -> bool:
		return result == Result.STUCK_DOT
	func is_stuck_goal() -> bool:
		return result == Result.STUCK_GOAL

	func turn_count() -> int:
		var ct := 0
		var last: Variant = null
		for move: Vector2 in moves:
			if last == null:
				last = move
				continue
			if last != move:
				ct += 1
			last = move
		return ct

## vars ####################################

var puzzle_node: DotHopPuzzle
var puzzle_state: PuzzleState
var move_fn: Callable

## init ####################################

func _init(opts: Dictionary) -> void:
	puzzle_node = opts.get("node")
	puzzle_state = opts.get("state")

	if puzzle_node != null:
		move_fn = puzzle_node.move
		puzzle_state = puzzle_node.state
	elif puzzle_state != null:
		move_fn = puzzle_state.move

## collect_move_tree ####################################

const all_dirs: Array[Vector2] = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]

func collect_move_tree(current_move_dict: Dictionary = {}, last_move: Variant = null) -> Variant:
	var any_moves: bool = false
	for dir: Vector2 in all_dirs:
		if last_move is Vector2 and dir == -1 * last_move:
			continue # skip 'undos'

		var move_res: PuzzleState.MoveResult = move_fn.call(dir)
		if move_res == PuzzleState.MoveResult.moved:
			any_moves = true
			current_move_dict[dir] = collect_move_tree({}, dir)
			move_fn.call(-1 * dir) # undo

	if any_moves:
		# we made a move, return this move-tree
		# TODO have we seen this move_tree before? two player puzzles can loop...
		return current_move_dict
	else:
		if puzzle_state.win:
			return MovePath.Result.WIN
		elif puzzle_state.all_players_at_goal():
			return MovePath.Result.STUCK_GOAL
		else:
			return MovePath.Result.STUCK_DOT

## collect_paths ####################################

func collect_paths(_move_tree: Variant, current_path: MovePath = null, _paths: Array[MovePath] = []) -> Array[MovePath]:
	if not _move_tree is Dictionary:
		# this is a test-only edge case, but if we can't make moves from the start...
		_paths.append(MovePath.new([]))
		return _paths

	if current_path == null:
		current_path = MovePath.new([])

	var filtered_mt := {}
	for dir: Vector2 in (_move_tree as Dictionary).keys():
		# ignore choices that would hit the goal early
		# TODO this should be behind a flag
		# (so game modes can early-exit puzzles if they want)
		if _move_tree[dir] is Dictionary or _move_tree[dir] != MovePath.Result.STUCK_GOAL:
			filtered_mt[dir] = _move_tree[dir]

	if len((filtered_mt as Dictionary).keys()) > 1:
		# differentiate between choice-2s and choice-3s?
		current_path.add_choice()

	for dir: Vector2 in (_move_tree as Dictionary).keys():
		var new_path: MovePath = current_path.create_branch() # new path for each move
		new_path.add_step(dir)

		# this is either the move tree or a MovePath.Result
		var res: Variant = _move_tree[dir]
		if res is Dictionary:
			# eep! we're modifying the MovePath in-place.
			collect_paths(res, new_path, _paths)
		elif MovePath.is_end_result(res):
			# i wonder what happens to this casted enum (null -> 0? or crash?)
			new_path.mark_result(res as MovePath.Result)
			_paths.append(new_path)

	return _paths

## analyze ####################################

var move_tree: Variant #: Dictionary | String
@export var paths: Array[MovePath]

@export var winning_paths: Array
@export var stuck_dot_paths: Array
@export var stuck_goal_paths: Array

@export var solvable: bool
@export var width: int = 0
@export var height: int = 0

@export var dot_count: int = 0

@export var path_count : int
@export var winning_path_count : int
@export var stuck_path_count : int
@export var stuck_dot_path_count : int
@export var stuck_goal_path_count : int

@export var least_choices_count: int = 0
@export var most_choices_count: int = 0
@export var least_turns_count: int = 0
@export var most_turns_count: int = 0

func analyze() -> PuzzleAnalysis:
	width = puzzle_state.grid_width
	height = puzzle_state.grid_height

	if len(puzzle_state.players) > 1:
		Log.warn("Puzzle Analysis for multi-hopper puzzles is not yet supported!")
		return self

	move_tree = collect_move_tree()
	paths = collect_paths(move_tree)

	winning_paths = paths.filter(func(p: MovePath) -> bool: return p.is_winning())
	stuck_dot_paths = paths.filter(func(p: MovePath) -> bool: return p.is_stuck_dot())
	stuck_goal_paths = paths.filter(func(p: MovePath) -> bool: return p.is_stuck_goal())

	path_count = len(paths)
	winning_path_count = len(winning_paths)
	stuck_path_count = len(paths) - len(winning_paths)
	stuck_dot_path_count = len(stuck_dot_paths)
	stuck_goal_path_count = len(stuck_goal_paths)

	solvable = len(winning_paths) > 0
	if solvable:
		dot_count = len(winning_paths[0].moves)

	for p: MovePath in winning_paths:
		var choice_ct := p.choices
		if choice_ct > most_choices_count:
			most_choices_count = choice_ct
		if least_choices_count == 0 or choice_ct < least_choices_count:
			least_choices_count = choice_ct

		var turn_ct := p.turn_count()
		if turn_ct > most_turns_count:
			most_turns_count = turn_ct
		if least_turns_count == 0 or turn_ct < least_turns_count:
			least_turns_count = turn_ct

	return self

func to_pretty() -> Variant:
	return {
		"width" = width,
		"height" = height,
		"dot_count" = dot_count,
		"winning_paths" = winning_path_count,
		"total_paths" = path_count,
		"most_choices_count" = most_choices_count,
		"least_choices_count" = least_choices_count,
		"most_turns_count" = most_turns_count,
		"least_turns_count" = least_turns_count,
		}

func analyze_in_background() -> Thread:
	var t := Thread.new()
	t.start(analyze)
	return t
