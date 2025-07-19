extends GdUnitTestSuite
class_name DotHopPuzzleTest

func build_puzzle(puzzle: Array) -> DotHopPuzzle:
	var puz_node := DotHopPuzzle.test_puzzle_node(puzzle)
	puz_node.randomize_layout = false
	puz_node.build_game_state()
	return puz_node

func test_basic_puzzle_one_win() -> void:
	var puzzle: DotHopPuzzle = build_puzzle(["xoot"])

	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[DHData.Obj.Player, DHData.Obj.Dotted], [DHData.Obj.Dot], [DHData.Obj.Dot], [DHData.Obj.Goal]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.RIGHT)
	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Player, DHData.Obj.Dotted], [DHData.Obj.Dot], [DHData.Obj.Goal]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.RIGHT)
	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[DHData.Obj.Dotted], [DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Player, DHData.Obj.Dotted], [DHData.Obj.Goal]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.RIGHT)
	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[DHData.Obj.Dotted], [DHData.Obj.Dotted], [DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Goal, DHData.Obj.Player]])
	assert_that(puzzle.state.win).is_equal(true)

	puzzle.free()

func test_basic_puzzle_one_undo() -> void:

	var puzzle: DotHopPuzzle = build_puzzle(["xoot"])

	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[DHData.Obj.Player, DHData.Obj.Dotted], [DHData.Obj.Dot], [DHData.Obj.Dot], [DHData.Obj.Goal]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.RIGHT)
	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Player, DHData.Obj.Dotted], [DHData.Obj.Dot], [DHData.Obj.Goal]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.RIGHT)
	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[DHData.Obj.Dotted], [DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Player, DHData.Obj.Dotted], [DHData.Obj.Goal]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.LEFT)
	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Dotted, DHData.Obj.Player], [DHData.Obj.Dot], [DHData.Obj.Goal]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.LEFT)
	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[DHData.Obj.Dotted, DHData.Obj.Player], [DHData.Obj.Dot], [DHData.Obj.Dot], [DHData.Obj.Goal]])
	assert_that(puzzle.state.win).is_equal(false)

	puzzle.free()

func test_two_player_puzzle_one_win() -> void:
	var puzzle: DotHopPuzzle = build_puzzle(["xoot", "xoot"])

	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[DHData.Obj.Player, DHData.Obj.Dotted], [DHData.Obj.Dot], [DHData.Obj.Dot], [DHData.Obj.Goal]])
	assert_that(puzzle.state.get_grid_row_objs(1)).is_equal(
		[[DHData.Obj.Player, DHData.Obj.Dotted], [DHData.Obj.Dot], [DHData.Obj.Dot], [DHData.Obj.Goal]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.RIGHT)
	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Player, DHData.Obj.Dotted], [DHData.Obj.Dot], [DHData.Obj.Goal]])
	assert_that(puzzle.state.get_grid_row_objs(1)).is_equal(
		[[DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Player, DHData.Obj.Dotted], [DHData.Obj.Dot], [DHData.Obj.Goal]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.RIGHT)
	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[DHData.Obj.Dotted], [DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Player, DHData.Obj.Dotted], [DHData.Obj.Goal]])
	assert_that(puzzle.state.get_grid_row_objs(1)).is_equal(
		[[DHData.Obj.Dotted], [DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Player, DHData.Obj.Dotted], [DHData.Obj.Goal]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.RIGHT)
	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[DHData.Obj.Dotted], [DHData.Obj.Dotted], [DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Goal, DHData.Obj.Player]])
	assert_that(puzzle.state.get_grid_row_objs(1)).is_equal(
		[[DHData.Obj.Dotted], [DHData.Obj.Dotted], [DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Goal, DHData.Obj.Player]])
	assert_that(puzzle.state.win).is_equal(true)
	puzzle.free()

func test_two_player_puzzle_one_undo() -> void:
	var puzzle: DotHopPuzzle = build_puzzle(["xoot", "xoot"])

	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[DHData.Obj.Player, DHData.Obj.Dotted], [DHData.Obj.Dot], [DHData.Obj.Dot], [DHData.Obj.Goal]])
	assert_that(puzzle.state.get_grid_row_objs(1)).is_equal(
		[[DHData.Obj.Player, DHData.Obj.Dotted], [DHData.Obj.Dot], [DHData.Obj.Dot], [DHData.Obj.Goal]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.RIGHT)
	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Player, DHData.Obj.Dotted], [DHData.Obj.Dot], [DHData.Obj.Goal]])
	assert_that(puzzle.state.get_grid_row_objs(1)).is_equal(
		[[DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Player, DHData.Obj.Dotted], [DHData.Obj.Dot], [DHData.Obj.Goal]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.RIGHT)
	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[DHData.Obj.Dotted], [DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Player, DHData.Obj.Dotted], [DHData.Obj.Goal]])
	assert_that(puzzle.state.get_grid_row_objs(1)).is_equal(
		[[DHData.Obj.Dotted], [DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Player, DHData.Obj.Dotted], [DHData.Obj.Goal]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.LEFT)
	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Dotted, DHData.Obj.Player], [DHData.Obj.Dot], [DHData.Obj.Goal]])
	assert_that(puzzle.state.get_grid_row_objs(1)).is_equal(
		[[DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Dotted, DHData.Obj.Player], [DHData.Obj.Dot], [DHData.Obj.Goal]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.LEFT)
	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[DHData.Obj.Dotted, DHData.Obj.Player], [DHData.Obj.Dot], [DHData.Obj.Dot], [DHData.Obj.Goal]])
	assert_that(puzzle.state.get_grid_row_objs(1)).is_equal(
		[[DHData.Obj.Dotted, DHData.Obj.Player], [DHData.Obj.Dot], [DHData.Obj.Dot], [DHData.Obj.Goal]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.free()

func test_undo_obj_is_not_duplicated() -> void:
	var puzzle: DotHopPuzzle = build_puzzle([
			"..oo",
			"txoo",
			"..oo",
			"txoo",
			])

	puzzle.move(Vector2.RIGHT)
	puzzle.move(Vector2.UP)
	puzzle.move(Vector2.RIGHT)
	puzzle.move(Vector2.UP)

	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[], [], [DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Player, DHData.Obj.Dotted]])
	assert_that(puzzle.state.get_grid_row_objs(2)).is_equal(
		[[], [], [DHData.Obj.Dotted], [DHData.Obj.Dotted, DHData.Obj.Undo]])

	puzzle.move(Vector2.DOWN)

	# This path was producing an extra DHData.Obj.Undo in the state grid,
	# when the second player didn't move during an undo
	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[], [], [DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Player, DHData.Obj.Dotted]])
	assert_that(puzzle.state.get_grid_row_objs(2)).is_equal(
		[[], [], [DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Dotted, DHData.Obj.Player]])

	puzzle.free()

func test_undo_obj_is_not_added_to_other_non_moving_player() -> void:
	var puzzle: DotHopPuzzle = build_puzzle([
			"....o.o",
			"tx..o.o",
			"oo.o.x.",
			"t......",
			])

	puzzle.move(Vector2.RIGHT)
	puzzle.move(Vector2.LEFT)
	puzzle.move(Vector2.LEFT)
	puzzle.move(Vector2.LEFT)

	assert_that(puzzle.state.get_grid_row_objs(1)).is_equal(
		[[DHData.Obj.Goal], [DHData.Obj.Dotted, DHData.Obj.Undo], [], [], [DHData.Obj.Player, DHData.Obj.Dotted], [], [DHData.Obj.Dot]])
	assert_that(puzzle.state.get_grid_row_objs(2)).is_equal(
		[[DHData.Obj.Player, DHData.Obj.Dotted], [DHData.Obj.Dotted, DHData.Obj.Undo], [], [DHData.Obj.Dotted], [], [DHData.Obj.Dotted], []])

	puzzle.move(Vector2.DOWN)

	assert_that(puzzle.state.get_grid_row_objs(1)).is_equal(
		[[DHData.Obj.Goal], [DHData.Obj.Dotted, DHData.Obj.Undo], [], [], [DHData.Obj.Player, DHData.Obj.Dotted], [], [DHData.Obj.Dot]])

	puzzle.move(Vector2.UP)

	# here we should have moved the top player's undo along
	assert_that(puzzle.state.get_grid_row_objs(1)).is_equal(
		[[DHData.Obj.Goal], [DHData.Obj.Dotted], [], [], [DHData.Obj.Dotted, DHData.Obj.Undo], [], [DHData.Obj.Dot]])

	puzzle.move(Vector2.RIGHT)
	puzzle.move(Vector2.DOWN)

	assert_that(puzzle.state.get_grid_row_objs(0)).is_equal(
		[[], [], [], [], [DHData.Obj.Dotted], [], [DHData.Obj.Dotted, DHData.Obj.Undo]])
	assert_that(puzzle.state.get_grid_row_objs(1)).is_equal(
		[[DHData.Obj.Goal], [DHData.Obj.Dotted # extra UNDO here?
			], [], [], [DHData.Obj.Dotted], [], [DHData.Obj.Player, DHData.Obj.Dotted]])
	assert_that(puzzle.state.get_grid_row_objs(2)).is_equal(
		[[DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Dotted], [], [DHData.Obj.Dotted], [], [DHData.Obj.Dotted], []])
	assert_that(puzzle.state.get_grid_row_objs(3)).is_equal(
		[[DHData.Obj.Goal, DHData.Obj.Player], [], [], [], [], [], []])

	puzzle.move(Vector2.LEFT)
	assert_that(puzzle.state.win).is_equal(true)

	puzzle.free()

func test_can_finish_puzzle_10() -> void:
	var puzzle: DotHopPuzzle = build_puzzle([
			"....o.o",
			"tx..o.o",
			"......t",
			"oo.o.x.",
			"oo.o..o",
			])

	puzzle.move(Vector2.RIGHT)
	puzzle.move(Vector2.LEFT)
	puzzle.move(Vector2.LEFT)
	puzzle.move(Vector2.LEFT)
	puzzle.move(Vector2.DOWN)
	puzzle.move(Vector2.UP)
	puzzle.move(Vector2.RIGHT)
	puzzle.move(Vector2.RIGHT)
	puzzle.move(Vector2.RIGHT)
	puzzle.move(Vector2.UP)
	puzzle.move(Vector2.DOWN)
	puzzle.move(Vector2.LEFT)

	assert_that(puzzle.state.win).is_equal(true)

	puzzle.free()

func test_can_undo_across_dotted_cells() -> void:
	var puzzle: DotHopPuzzle = build_puzzle([
			"oooo.",
			"oxoot",
			"..oo.",
			])

	puzzle.move(Vector2.RIGHT)
	puzzle.move(Vector2.RIGHT)
	puzzle.move(Vector2.UP)
	puzzle.move(Vector2.LEFT)
	puzzle.move(Vector2.LEFT)
	puzzle.move(Vector2.LEFT)
	puzzle.move(Vector2.DOWN)
	puzzle.move(Vector2.RIGHT)

	assert_that(puzzle.state.get_grid_row_objs(1)).is_equal(
		[[DHData.Obj.Dotted, DHData.Obj.Undo], [DHData.Obj.Dotted], [DHData.Obj.Dotted], [DHData.Obj.Dotted], [DHData.Obj.Goal, DHData.Obj.Player]])
	assert_that(puzzle.state.players[0].stuck).is_equal(true)

	puzzle.move(Vector2.LEFT)

	assert_that(puzzle.state.players[0].stuck).is_equal(false)
	assert_that(puzzle.state.get_grid_row_objs(1)).is_equal(
		[[DHData.Obj.Dotted, DHData.Obj.Player], [DHData.Obj.Dotted], [DHData.Obj.Dotted], [DHData.Obj.Dotted], [DHData.Obj.Goal]])

	puzzle.free()
