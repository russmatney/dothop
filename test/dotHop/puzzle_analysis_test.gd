extends GdUnitTestSuite
class_name PuzzleAnalysisTest


func build_puzzle(puzzle: Array) -> DotHopPuzzle:
	var puzzle_node := DotHopPuzzle.test_puzzle_node(puzzle)
	puzzle_node.build_game_state()
	return puzzle_node

## test the solver ##################################################

@warning_ignore("unused_parameter")
func test_puzzle_solver_basic(puzz: Array, solvable: bool, test_parameters: Array = [
		[["xot"], true],
		[[
			"x.",
			"ot"
			], true],
		[[
			"oxot",
			"ooo."
			], true],
		[[
			".x..", # branch from not-the-start
			"ooot",
			"ooo."
			], true],
		[["x.", ".t"], false],
		[[
			"o..o.o.",
			"ox.o.ot",
			"...o.o.",
			], true],
		# [[ # multi-hoppers not yet supported
		# 	"..oo",
		# 	"txoo",
		# 	"..oo",
		# 	"txoo",
		# 	], true]
	]) -> void:
	var puzzle := build_puzzle(puzz)
	var result := PuzzleAnalysis.new({node=puzzle}).analyze()
	assert_bool(result.solvable).is_equal(solvable)

	puzzle.free()


@warning_ignore("unused_parameter")
func test_puzzle_solver_analysis(puzz: Array, expected_result: Dictionary, test_parameters: Array = [
		[["xot"], {
			solvable=true,
			path_count=1, winning_path_count=1, stuck_path_count=0,
			least_choices_count=0, most_choices_count=0,
			least_turns_count=0, most_turns_count=0,
			}],
		[[
			"x.",
			"ot"
			], {
			solvable=true,
			path_count=1, winning_path_count=1, stuck_path_count=0,
			least_choices_count=0, most_choices_count=0,
			least_turns_count=1, most_turns_count=1,
			}],
		[[
			"oxot",
			"ooo."
			], {
			solvable=true,
			path_count=7, winning_path_count=2, stuck_path_count=5,
			least_choices_count=1, most_choices_count=1,
			least_turns_count=4, most_turns_count=4,
			}],
		[[
			".x..", # branch from not-the-start
			"ooot",
			"ooo."
			], {
			solvable=true,
			path_count=7, winning_path_count=2, stuck_path_count=5,
			least_choices_count=1, most_choices_count=1,
			least_turns_count=5, most_turns_count=5,
			}],
		[[
			"..x..", # prove turn counts can be different
			"oooo.",
			"oooot"
			], {
			solvable=true,
			path_count=18, winning_path_count=4, stuck_path_count=14,
			least_choices_count=2, most_choices_count=3,
			least_turns_count=5, most_turns_count=7,
			}],
		[["x.", ".t"], {
			solvable=false,
			path_count=1, winning_path_count=0, stuck_path_count=1,
			least_choices_count=0, most_choices_count=0,
			least_turns_count=0, most_turns_count=0,
			}],
		[[
			"o.oo.",
			"oxoot",
			"..oo.",
			], {
			solvable=true,
			path_count=22, winning_path_count=2, stuck_path_count=20,
			least_choices_count=3, most_choices_count=3,
			least_turns_count=6, most_turns_count=6,
			}],
	]) -> void:
	var puzzle := build_puzzle(puzz)

	var result := PuzzleAnalysis.new({node=puzzle}).analyze()

	for k: String in expected_result:
		assert_that(expected_result[k]).append_failure_message(str(k, " | ", puzz[0])).is_equal(result.get(k))

	puzzle.free()

## test in-game puzzles ##################################################

func test_all_puzzles_solvable_via_state() -> void:
	var worlds := Store.get_worlds()
	assert_int(len(worlds)).is_greater(3) # make sure we get some

	# TODO refactor to pull all puzzles from a PuzzleStore

	for x in range(len(worlds)):
		var world: PuzzleWorld = worlds[x]
		var psd := world.get_puzzle_set_data()
		var puzzle_count := len(psd.puzzle_defs)
		assert_int(puzzle_count).is_greater(0)
		for i in puzzle_count:
			var puzz_state := PuzzleState.new(psd.puzzle_defs[i])
			if len(puzz_state.players) > 1:
				Log.warn("Puzzle Analysis for multi-hopper puzzles is not yet supported!")
				continue
			Log.info("Solving puzzle:", world.get_display_name(), str(x+1, "-", i+1))
			var solve := PuzzleAnalysis.new({state=puzz_state}).analyze()
			# Log.pr(["Puzzle:", world.get_display_name(), i, solve])
			var choice_s := str(solve.least_choices_count, " / ", solve.most_choices_count)
			var turn_s := str(solve.least_turns_count, " / ", solve.most_turns_count)
			if solve.winning_path_count == 1 or solve.least_choices_count == solve.most_choices_count:
				choice_s = str(solve.least_choices_count)
			if solve.winning_path_count == 1 or solve.least_turns_count == solve.most_turns_count:
				turn_s = str(solve.least_turns_count)
			Log.info(str("| ", world.get_display_name(),
				" | [", x+1, "-", i+1, "](#_", x+1, "-", i+1, ") | ",
				solve.dot_count, " | ",
				solve.winning_path_count, " / ", solve.path_count, " | ",
				choice_s, " | ",
				turn_s, " |",
				))
			if not solve.solvable:
				Log.pr("Unsolvable puzzle!!", world.get_display_name(), "num:", i)
			assert_bool(solve.solvable).is_true()

func test_all_puzzles_solvable_via_node() -> void:
	var worlds := Store.get_worlds()
	assert_int(len(worlds)).is_greater(3) # make sure we get some

	# test ONE random puzzle from each world
	for world: PuzzleWorld in worlds:
		var psd := world.get_puzzle_set_data()
		var puzzle_count := len(psd.puzzle_defs)
		assert_int(puzzle_count).is_greater(0)

		# run for a random one for each puzzle set
		# (the puzzle solutions are tested thoroughly by the previous test)
		var i: int = randi_range(0, puzzle_count - 1)

		var puzz_node := DotHopPuzzle.build_puzzle_node({world=world, puzzle_def=psd.puzzle_defs[i]})
		puzz_node.build_game_state()
		if len(puzz_node.state.players) > 1:
			Log.warn("Puzzle Analysis for multi-hopper puzzles is not yet supported!")
			puzz_node.queue_free()
			continue
		add_child(puzz_node)

		Log.info(["Solving Puzzle node:", world.get_display_name(), i])
		var solve := PuzzleAnalysis.new({node=puzz_node}).analyze()
		Log.info(["Puzzle:", world.get_display_name(), i, solve])
		if not solve.solvable:
			Log.pr("Unsolvable puzzle!!", world.get_display_name(), "num:", i)
		assert_bool(solve.solvable).is_true()

		remove_child(puzz_node)
		puzz_node.queue_free()
