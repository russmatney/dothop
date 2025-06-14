extends GdUnitTestSuite
class_name DotHopTest

func build_puzzle(puzzle: Array) -> DotHopPuzzle:
	var puz_node := DotHopPuzzle.build_puzzle_node({puzzle=puzzle})
	puz_node.randomize_layout = false
	puz_node.build_game_state()
	return puz_node

func test_basic_puzzle_one_win() -> void:
	var puzzle: DotHopPuzzle = build_puzzle(["xoot"])

	assert_that(puzzle.state.grid[0]).is_equal(
		[["Player", "Dotted"], ["Dot"], ["Dot"], ["Goal"]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.RIGHT)
	assert_that(puzzle.state.grid[0]).is_equal(
		[["Dotted", "Undo"], ["Player", "Dotted"], ["Dot"], ["Goal"]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.RIGHT)
	assert_that(puzzle.state.grid[0]).is_equal(
		[["Dotted"], ["Dotted", "Undo"], ["Player", "Dotted"], ["Goal"]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.RIGHT)
	assert_that(puzzle.state.grid[0]).is_equal(
		[["Dotted"], ["Dotted"], ["Dotted", "Undo"], ["Goal", "Player"]])
	assert_that(puzzle.state.win).is_equal(true)

	puzzle.free()

func test_basic_puzzle_one_undo() -> void:

	var puzzle: DotHopPuzzle = build_puzzle(["xoot"])

	assert_that(puzzle.state.grid[0]).is_equal(
		[["Player", "Dotted"], ["Dot"], ["Dot"], ["Goal"]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.RIGHT)
	assert_that(puzzle.state.grid[0]).is_equal(
		[["Dotted", "Undo"], ["Player", "Dotted"], ["Dot"], ["Goal"]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.RIGHT)
	assert_that(puzzle.state.grid[0]).is_equal(
		[["Dotted"], ["Dotted", "Undo"], ["Player", "Dotted"], ["Goal"]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.LEFT)
	assert_that(puzzle.state.grid[0]).is_equal(
		[["Dotted", "Undo"], ["Dotted", "Player"], ["Dot"], ["Goal"]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.LEFT)
	assert_that(puzzle.state.grid[0]).is_equal(
		[["Dotted", "Player"], ["Dot"], ["Dot"], ["Goal"]])
	assert_that(puzzle.state.win).is_equal(false)

	puzzle.free()

func test_two_player_puzzle_one_win() -> void:
	var puzzle: DotHopPuzzle = build_puzzle(["xoot", "xoot"])

	assert_that(puzzle.state.grid[0]).is_equal(
		[["Player", "Dotted"], ["Dot"], ["Dot"], ["Goal"]])
	assert_that(puzzle.state.grid[1]).is_equal(
		[["Player", "Dotted"], ["Dot"], ["Dot"], ["Goal"]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.RIGHT)
	assert_that(puzzle.state.grid[0]).is_equal(
		[["Dotted", "Undo"], ["Player", "Dotted"], ["Dot"], ["Goal"]])
	assert_that(puzzle.state.grid[1]).is_equal(
		[["Dotted", "Undo"], ["Player", "Dotted"], ["Dot"], ["Goal"]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.RIGHT)
	assert_that(puzzle.state.grid[0]).is_equal(
		[["Dotted"], ["Dotted", "Undo"], ["Player", "Dotted"], ["Goal"]])
	assert_that(puzzle.state.grid[1]).is_equal(
		[["Dotted"], ["Dotted", "Undo"], ["Player", "Dotted"], ["Goal"]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.RIGHT)
	assert_that(puzzle.state.grid[0]).is_equal(
		[["Dotted"], ["Dotted"], ["Dotted", "Undo"], ["Goal", "Player"]])
	assert_that(puzzle.state.grid[1]).is_equal(
		[["Dotted"], ["Dotted"], ["Dotted", "Undo"], ["Goal", "Player"]])
	assert_that(puzzle.state.win).is_equal(true)
	puzzle.free()

func test_two_player_puzzle_one_undo() -> void:
	var puzzle: DotHopPuzzle = build_puzzle(["xoot", "xoot"])

	assert_that(puzzle.state.grid[0]).is_equal(
		[["Player", "Dotted"], ["Dot"], ["Dot"], ["Goal"]])
	assert_that(puzzle.state.grid[1]).is_equal(
		[["Player", "Dotted"], ["Dot"], ["Dot"], ["Goal"]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.RIGHT)
	assert_that(puzzle.state.grid[0]).is_equal(
		[["Dotted", "Undo"], ["Player", "Dotted"], ["Dot"], ["Goal"]])
	assert_that(puzzle.state.grid[1]).is_equal(
		[["Dotted", "Undo"], ["Player", "Dotted"], ["Dot"], ["Goal"]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.RIGHT)
	assert_that(puzzle.state.grid[0]).is_equal(
		[["Dotted"], ["Dotted", "Undo"], ["Player", "Dotted"], ["Goal"]])
	assert_that(puzzle.state.grid[1]).is_equal(
		[["Dotted"], ["Dotted", "Undo"], ["Player", "Dotted"], ["Goal"]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.LEFT)
	assert_that(puzzle.state.grid[0]).is_equal(
		[["Dotted", "Undo"], ["Dotted", "Player"], ["Dot"], ["Goal"]])
	assert_that(puzzle.state.grid[1]).is_equal(
		[["Dotted", "Undo"], ["Dotted", "Player"], ["Dot"], ["Goal"]])
	assert_that(puzzle.state.win).is_equal(false)
	puzzle.move(Vector2.LEFT)
	assert_that(puzzle.state.grid[0]).is_equal(
		[["Dotted", "Player"], ["Dot"], ["Dot"], ["Goal"]])
	assert_that(puzzle.state.grid[1]).is_equal(
		[["Dotted", "Player"], ["Dot"], ["Dot"], ["Goal"]])
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

	assert_that(puzzle.state.grid[0]).is_equal(
		[null, null, ["Dotted", "Undo"], ["Player", "Dotted"]])
	assert_that(puzzle.state.grid[2]).is_equal(
		[null, null, ["Dotted"], ["Dotted", "Undo"]])

	puzzle.move(Vector2.DOWN)

	# This path was producing an extra "Undo" in the state grid,
	# when the second player didn't move during an undo
	assert_that(puzzle.state.grid[0]).is_equal(
		[null, null, ["Dotted", "Undo"], ["Player", "Dotted"]])
	assert_that(puzzle.state.grid[2]).is_equal(
		[null, null, ["Dotted", "Undo"], ["Dotted", "Player"]])

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

	assert_that(puzzle.state.grid[1]).is_equal(
		[["Goal"], ["Dotted", "Undo"], null, null, ["Player", "Dotted"], null, ["Dot"]])
	assert_that(puzzle.state.grid[2]).is_equal(
		[["Player", "Dotted"], ["Dotted", "Undo"], null, ["Dotted"], null, ["Dotted"], null])

	puzzle.move(Vector2.DOWN)

	assert_that(puzzle.state.grid[1]).is_equal(
		[["Goal"], ["Dotted", "Undo"], null, null, ["Player", "Dotted"], null, ["Dot"]])

	puzzle.move(Vector2.UP)

	# here we should have moved the top player's undo along
	assert_that(puzzle.state.grid[1]).is_equal(
		[["Goal"], ["Dotted"], null, null, ["Dotted", "Undo"], null, ["Dot"]])

	puzzle.move(Vector2.RIGHT)
	puzzle.move(Vector2.DOWN)

	assert_that(puzzle.state.grid[0]).is_equal(
		[null, null, null, null, ["Dotted"], null, ["Dotted", "Undo"]])
	assert_that(puzzle.state.grid[1]).is_equal(
		[["Goal"], ["Dotted" # extra UNDO here?
			], null, null, ["Dotted"], null, ["Player", "Dotted"]])
	assert_that(puzzle.state.grid[2]).is_equal(
		[["Dotted", "Undo"], ["Dotted"], null, ["Dotted"], null, ["Dotted"], null])
	assert_that(puzzle.state.grid[3]).is_equal(
		[["Goal", "Player"], null, null, null, null, null, null])

	puzzle.move(Vector2.LEFT)
	assert_that(puzzle.state.win).is_equal(true)

	puzzle.free()

	# assert_that(puzzle.state.grid[2],
	# 	[null, null, ["Dotted"], ["Dotted", "Undo"]])

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

	assert_that(puzzle.state.grid[1]).is_equal(
		[["Dotted", "Undo"], ["Dotted"], ["Dotted"], ["Dotted"], ["Goal", "Player"]])
	assert_that(puzzle.state.players[0].stuck).is_equal(true)

	puzzle.move(Vector2.LEFT)

	assert_that(puzzle.state.players[0].stuck).is_equal(false)
	assert_that(puzzle.state.grid[1]).is_equal(
		[["Dotted", "Player"], ["Dotted"], ["Dotted"], ["Dotted"], ["Goal"]])

	puzzle.free()
