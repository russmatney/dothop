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
	var result := PuzzleAnalysis.new(puzzle).analyze()
	assert_bool(result.solvable).is_equal(solvable)

	puzzle.free()


@warning_ignore("unused_parameter")
func test_puzzle_solver_analysis(puzz: Array, expected_result: Dictionary, test_parameters: Array = [
		[["xot"], {
			solvable=true,
			path_count=1, winning_path_count=1, stuck_path_count=0,
			}],
		[[
			"x.",
			"ot"
			], {
			solvable=true,
			path_count=1, winning_path_count=1, stuck_path_count=0,
			}],
		[[
			"oxot",
			"ooo."
			], {
			solvable=true,
			path_count=7, winning_path_count=2, stuck_path_count=5,
			}],
		[[
			".x..", # branch from not-the-start
			"ooot",
			"ooo."
			], {
			solvable=true,
			path_count=7, winning_path_count=2, stuck_path_count=5,
			}],
		[["x.", ".t"], {
			solvable=false,
			path_count=1, winning_path_count=0, stuck_path_count=1,
			}],
		[[
			"o.oo.",
			"oxoot",
			"..oo.",
			], {
			solvable=true,
			path_count=22, winning_path_count=2, stuck_path_count=20,
			}],
	]) -> void:
	var puzzle := build_puzzle(puzz)

	var result := PuzzleAnalysis.new(puzzle).analyze()

	for k: String in expected_result:
		assert_that(expected_result[k]).is_equal(result.get(k))

	puzzle.free()

## test in-game puzzles ##################################################

func test_all_puzzles_solvable() -> void:
	var sets := Store.get_puzzle_sets()
	assert_int(len(sets)).is_greater(3) # make sure we get some

	for puzzle_set: PuzzleSet in sets:
		var game_def := puzzle_set.get_game_def()
		var puzzle_count := len(game_def.puzzles)
		assert_int(puzzle_count).is_greater(0)
		for i in puzzle_count:
			# requiring a node that is added to the scene to analyze is a damn shame here
			# (can the analysis be run without the node's _ready()?
			var puzz_node := DotHopPuzzle.build_puzzle_node({
				game_def=game_def,
				puzzle_num=i,
				})
			puzz_node.build_game_state()

			var solve := PuzzleAnalysis.new(puzz_node).analyze()
			Log.pr(["Puzzle:", puzzle_set.get_display_name(), "num:", i,
				"solvable?", solve.solvable,
				"dot count", solve.dot_count,
				"winning paths:", solve.winning_path_count,
				"total paths:", solve.path_count,
				"width", solve.width,
				"height", solve.height,
				])
			if not solve.solvable:
				Log.pr("Unsolvable puzzle!!", puzzle_set.get_display_name(), "num:", i)
			assert_bool(solve.solvable).is_true()

			puzz_node.free()
