extends GdUnitTestSuite
class_name PuzzleAnalysisTest


func build_puzzle(puzzle: Array) -> DotHopPuzzle:
	var puzzle_node := DotHopPuzzle.build_puzzle_node({puzzle=puzzle})
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
			least_choices_count=1, most_choices_count=2,
			least_turns_count=4, most_turns_count=4,
			}],
		[[
			".x..", # branch from not-the-start
			"ooot",
			"ooo."
			], {
			solvable=true,
			path_count=7, winning_path_count=2, stuck_path_count=5,
			least_choices_count=1, most_choices_count=2,
			least_turns_count=5, most_turns_count=5,
			}],
		[[
			"..x..", # prove turn counts can be different
			"oooo.",
			"oooot"
			], {
			solvable=true,
			path_count=18, winning_path_count=4, stuck_path_count=14,
			least_choices_count=3, most_choices_count=4,
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
		assert_that(expected_result[k]).append_failure_message(k).is_equal(result.get(k))

	puzzle.free()

## test in-game puzzles ##################################################

# func test_all_puzzles_solvable_via_state() -> void:
# 	var sets := Store.get_puzzle_sets()
# 	assert_int(len(sets)).is_greater(3) # make sure we get some

# 	for x in range(len(sets)):
# 		var puzzle_set: PuzzleSet = sets[x]
# 		var game_def := puzzle_set.get_game_def()
# 		var puzzle_count := len(game_def.puzzles)
# 		assert_int(puzzle_count).is_greater(0)
# 		for i in puzzle_count:
# 			var puzz_state := PuzzleState.new(game_def.puzzles[i], game_def)
# 			var solve := PuzzleAnalysis.new({state=puzz_state}).analyze()
# 			Log.pr(["Puzzle:", puzzle_set.get_display_name(), i, solve])
# 			if not solve.solvable:
# 				Log.pr("Unsolvable puzzle!!", puzzle_set.get_display_name(), "num:", i)
# 			assert_bool(solve.solvable).is_true()

# func test_all_puzzles_solvable_via_node() -> void:
# 	var sets := Store.get_puzzle_sets()
# 	assert_int(len(sets)).is_greater(3) # make sure we get some

# 	for puzzle_set: PuzzleSet in sets:
# 		var game_def := puzzle_set.get_game_def()
# 		var puzzle_count := len(game_def.puzzles)
# 		assert_int(puzzle_count).is_greater(0)

# 		# run for a random one for each puzzle set
# 		# (the puzzle solutions are tested thoroughly by the previous test)
# 		var i: int = randi_range(0, puzzle_count - 1)

# 		var puzz_node := DotHopPuzzle.build_puzzle_node({
# 			game_def=game_def,
# 			puzzle_num=i,
# 			})
# 		puzz_node.build_game_state()

# 		var solve := PuzzleAnalysis.new({node=puzz_node}).analyze()
# 		Log.pr(["Puzzle:", puzzle_set.get_display_name(), i, solve])
# 		if not solve.solvable:
# 			Log.pr("Unsolvable puzzle!!", puzzle_set.get_display_name(), "num:", i)
# 		assert_bool(solve.solvable).is_true()

# 		puzz_node.free()
