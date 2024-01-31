extends GdUnitTestSuite
class_name PuzzleSolverTest


func build_puzzle(puzzle):
	return DotHopPuzzle.build_puzzle_node({puzzle=puzzle,
		game_def_path="res://src/puzzles/dothop.txt"})


func solve(node):
	var s = Solver.new(node)

	var move_tree = s.build_move_tree()
	Log.prn("move_tree", move_tree)

	return {solveable=false}


func test_puzzle_solver_basic(puzz, solveable, test_parameters=[
		[["xoot"], true],
		[["x.", ".t"], false],
		[[
			"o..o.o.",
			"ox.o.ot",
			"...o.o.",
			], true],
	]):
	var puzzle = build_puzzle(puzz)
	add_child(puzzle)

	Log.pr("solving puzzle", puzz)
	var result = solve(puzzle)

	assert_bool(result.solveable).is_equal(solveable)

	puzzle.free()
