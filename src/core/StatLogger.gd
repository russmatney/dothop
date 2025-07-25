extends Object
class_name StatLogger

static func md_link(txt: String, uri: String) -> String:
	return str("[", txt, "](", uri, ")")

## public

class PuzzCtx:
	var world: PuzzleWorld
	var world_i: int
	var puzzle_i: int
	var state: PuzzleState
	var solve: PuzzleAnalysis

	func _init(_state: PuzzleState, _set: PuzzleWorld, wi: int, pi: int) -> void:
		state = _state
		world = _set
		world_i = wi
		puzzle_i = pi

	func analyze() -> void:
		Log.info(["Analyzing puzzle:", world.get_display_name(), puzzle_i])
		solve = PuzzleAnalysis.new({state=state})
		solve.analyze()
		Log.info(["Finished analyzing puzzle:", world.get_display_name(), puzzle_i])

	# TODO reuse if already run - maybe by attaching analysis to the state?
	func analyze_in_background() -> Thread:
		Log.info(["Analyzing puzzle in bg:", world.get_display_name(), puzzle_i])
		solve = PuzzleAnalysis.new({state=state})
		return solve.analyze_in_background()

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
		var world_name := world.get_display_name()

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

		data["world_name"] = world.get_display_name()
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
	var worlds := Store.get_worlds()
	# worlds = worlds.duplicate()

	# limit to first world
	# worlds = worlds[0]
	# limit to last world
	# worlds = [worlds[-1]]
	# drop last world
	# worlds = worlds.duplicate()
	# worlds.pop_back()

	for world_i in range(len(worlds)):
		var world: PuzzleWorld = worlds[world_i]
		var psd := world.get_puzzle_set_data()
		var puzzle_count := len(psd.puzzle_defs)

		for puzzle_i in puzzle_count:
			var puzz_state := PuzzleState.new(psd.puzzle_defs[puzzle_i])
			ctxs.append(PuzzCtx.new(puzz_state, world, world_i, puzzle_i))

	return ctxs

static func write_json(json_data: Array[Dictionary]) -> void:
	var json_data_path := "res://data/puzzle_data.json"
	Log.info("Writing Puzzle Data to", json_data_path)
	var json_blob := JSON.stringify(json_data, "  ")
	var json_file := FileAccess.open(json_data_path, FileAccess.WRITE)
	json_file.store_string(json_blob)
	Log.info("JSON Puzzle Data written to", json_data_path)

static func write_md_table(md_table: Array[String]) -> void:
	var md_table_path := "res://data/puzzle_data.md"
	Log.info("Writing Puzzle Data to", md_table_path)
	var md_file := FileAccess.open(md_table_path, FileAccess.WRITE)
	md_file.store_string("\n".join(md_table))
	Log.info("Markdown Puzzle Data written to", md_table_path)

## export puzzle data

static func export_puzzle_data() -> void:
	Log.info("Exporting puzzle data!")

	var puzzle_ctxs := build_puzzle_ctxs()

	var json_data : Array[Dictionary] = []
	var md_table : Array[String] = []

	for ctx in puzzle_ctxs:
		ctx.analyze()

		md_table.append(ctx.table_line())
		json_data.append(ctx.json_data())

	StatLogger.write_json(json_data)
	StatLogger.write_md_table(md_table)

## export puzzle data in bg

static func export_puzzle_data_in_background() -> Thread:
	var t := Thread.new()

	t.start(run_export_in_bg)

	return t

static func run_export_in_bg() -> void:
	var puzzle_ctxs := build_puzzle_ctxs()

	var json_data : Array[Dictionary] = []
	var md_table : Array[String] = []

	for ctx in puzzle_ctxs:
		# TODO run in parallel groups
		var pt := ctx.analyze_in_background()
		# immediately wait to finish (joining this bg thread back)
		pt.wait_to_finish()
		Log.info("Finished analyzing:", ctx.puzzle_id())

	for ctx in puzzle_ctxs:
		md_table.append(ctx.table_line())
		json_data.append(ctx.json_data())

	StatLogger.write_json(json_data)
	StatLogger.write_md_table(md_table)
