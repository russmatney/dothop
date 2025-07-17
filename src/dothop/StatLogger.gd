extends Object
class_name StatLogger


## public

class PuzzCtx:
	var puzzle_set: PuzzleSet
	var world_i: int
	var puzzle_i: int
	var state: PuzzleState
	var solve: PuzzleAnalysis

	func _init(_state: PuzzleState, _set: PuzzleSet, wi: int, pi: int) -> void:
		state = _state
		puzzle_set = _set
		world_i = wi
		puzzle_i = pi

	func analyze() -> void:
		Log.info(["Analyzing puzzle:", puzzle_set.get_display_name(), puzzle_i])
		solve = PuzzleAnalysis.new({state=state}).analyze()
		Log.info(["Finished analyzing puzzle:", puzzle_set.get_display_name(), puzzle_i])

	func table_line() -> String:
		var choice_s := str(solve.least_choices_count, " / ", solve.most_choices_count)
		var turn_s := str(solve.least_turns_count, " / ", solve.most_turns_count)
		if solve.winning_path_count == 1 or solve.least_choices_count == solve.most_choices_count:
			choice_s = str(solve.least_choices_count)
		if solve.winning_path_count == 1 or solve.least_turns_count == solve.most_turns_count:
			turn_s = str(solve.least_turns_count)

		# join fields with table seperator
		return " | ".join([
			puzzle_set.get_display_name(),
			str("[", world_i+1, "-", puzzle_i+1, "](#_", world_i+1, "-", puzzle_i+1, ")"),
			solve.dot_count,
			solve.winning_path_count, " / ", solve.path_count,
			choice_s,
			turn_s,
			])


static func build_puzzle_ctxs() -> Array[PuzzCtx]:
	var ctxs: Array[PuzzCtx] = []
	var sets := Store.get_puzzle_sets()

	for world_i in range(len(sets)):
		var puzzle_set: PuzzleSet = sets[world_i]
		var game_def := puzzle_set.get_game_def()
		var puzzle_count := len(game_def.puzzles)

		for puzzle_i in puzzle_count:
			var puzz_state := PuzzleState.new(game_def.puzzles[puzzle_i], game_def)
			ctxs.append(PuzzCtx.new(puzz_state, puzzle_set, world_i, puzzle_i))

	return ctxs


static func log_puzzle_data() -> void:
	Log.pr("Logging puzzle data!")

	var puzzle_ctxs := build_puzzle_ctxs()

	for ctx in puzzle_ctxs:
		# TODO parallelize
		ctx.analyze()

		var table_line := ctx.table_line()

		Log.pr(table_line)

		# TODO write data files to disk
