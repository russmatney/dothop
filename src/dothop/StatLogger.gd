extends Object
class_name StatLogger

static func md_link(txt: String, uri: String) -> String:
	return str("[", txt, "](", uri, ")")

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

	func puzzle_id() -> String:
		return str(world_i+1, "-", puzzle_i+1)

	func choice_sum() -> String:
		if solve.winning_path_count == 1 or solve.least_choices_count == solve.most_choices_count:
			return str(solve.least_choices_count)
		return str(solve.least_choices_count, " / ", solve.most_choices_count)

	func turn_sum() -> String:
		if solve.winning_path_count == 1 or solve.least_turns_count == solve.most_turns_count:
			return str(solve.least_turns_count)
		return str(solve.least_turns_count, " / ", solve.most_turns_count)

	func path_sum() -> String:
		return str(solve.winning_path_count, " / ", solve.path_count)

	func puzzle_lines() -> Array[String]:
		var lines : Array[String] = []
		for row: Array in state.puzzle_def.shape:
			var line := "".join(row.map(func(cell: Variant) -> String:
				return str(cell) if cell != null else "."))
			lines.append(line)
		return lines

	func raw_puzzle_lines() -> Array:
		return state.puzzle_def.shape

	func table_line() -> String:
		var p_id := puzzle_id()
		var world_name := puzzle_set.get_display_name()

		# fields with table seperator
		# maybe re-use json_data.values()? or otherwise go data-driven
		return str(" | ", " | ".join([
			# md links for blog post
			StatLogger.md_link(world_name, str("#", world_name)),
			StatLogger.md_link(p_id, str("#_", p_id)),
			solve.dot_count,
			path_sum(),
			choice_sum(),
			turn_sum(),
			]), " | ")

	func json_data() -> Dictionary:
		var data: Dictionary = solve.to_pretty()

		data["world_name"] = puzzle_set.get_display_name()
		data["puzzle_id"] = puzzle_id()

		data["puzzle_lines"] = puzzle_lines()
		data["raw_puzzle_lines"] = raw_puzzle_lines()

		data["path_sum"] = path_sum()
		data["choice_sum"] = choice_sum()
		data["turn_sum"] = turn_sum()

		data["world_i"] = world_i
		data["puzzle_i"] = puzzle_i

		# join fields with table seperator
		return data


static func build_puzzle_ctxs() -> Array[PuzzCtx]:
	var ctxs: Array[PuzzCtx] = []
	var sets := Store.get_puzzle_sets()

	for world_i in range(len(sets)):
		var puzzle_set: PuzzleSet = sets[world_i]
		var psd := puzzle_set.get_puzzle_set_data()
		var puzzle_count := len(psd.puzzle_defs)

		for puzzle_i in puzzle_count:
			var puzz_state := PuzzleState.new(psd.puzzle_defs[puzzle_i])
			ctxs.append(PuzzCtx.new(puzz_state, puzzle_set, world_i, puzzle_i))

	return ctxs


static func export_puzzle_data() -> void:
	Log.info("Exporting puzzle data!")

	var puzzle_ctxs := build_puzzle_ctxs()

	var json_data : Array[Dictionary] = []
	var md_table : Array[String] = []

	for ctx in puzzle_ctxs:
		# TODO parallelize/background the analysis
		ctx.analyze()

		md_table.append(ctx.table_line())
		json_data.append(ctx.json_data())

	var json_data_path := "res://data/puzzle_data.json"
	Log.info("Writing Puzzle Data to", json_data_path)
	var json_blob := JSON.stringify(json_data, "  ")
	var json_file := FileAccess.open(json_data_path, FileAccess.WRITE)
	json_file.store_string(json_blob)
	Log.info("JSON Puzzle Data written to", json_data_path)

	var md_table_path := "res://data/puzzle_data.md"
	Log.info("Writing Puzzle Data to", md_table_path)
	var md_file := FileAccess.open(md_table_path, FileAccess.WRITE)
	md_file.store_string("\n".join(md_table))
	Log.info("Markdown Puzzle Data written to", md_table_path)
