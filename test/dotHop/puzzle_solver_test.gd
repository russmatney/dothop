extends GdUnitTestSuite
class_name PuzzleSolverTest


func build_puzzle(puzzle):
	return DotHopPuzzle.build_puzzle_node({puzzle=puzzle,
		game_def_path="res://src/puzzles/dothop.txt"})


func test_puzzle_solver_basic(puzz, solveable, test_parameters=[
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
	]):
	var puzzle = build_puzzle(puzz)
	add_child(puzzle)
	var result = Solver.new(puzzle).analyze()
	assert_bool(result.solveable).is_equal(solveable)

	puzzle.free()


func test_puzzle_solver_analysis(puzz, expected_result, test_parameters=[
		[["xot"], {
			solveable=true,
			path_count=1, winning_path_count=1, stuck_path_count=0,
			}],
		[[
			"x.",
			"ot"
			], {
			solveable=true,
			path_count=1, winning_path_count=1, stuck_path_count=0,
			}],
		[[
			"oxot",
			"ooo."
			], {
			solveable=true,
			path_count=7, winning_path_count=2, stuck_path_count=5,
			}],
		[[
			".x..", # branch from not-the-start
			"ooot",
			"ooo."
			], {
			solveable=true,
			path_count=7, winning_path_count=2, stuck_path_count=5,
			}],
		[["x.", ".t"], {
			solveable=false,
			path_count=1, winning_path_count=0, stuck_path_count=1,
			}],
		[[
			"o.oo.",
			"oxoot",
			"..oo.",
			], {
			solveable=true,
			path_count=22, winning_path_count=2, stuck_path_count=20,
			}],
	]):
	var puzzle = build_puzzle(puzz)
	add_child(puzzle)

	var result = Solver.new(puzzle).analyze()

	for k in expected_result:
		assert_that(expected_result[k]).is_equal(result[k])

	puzzle.free()
