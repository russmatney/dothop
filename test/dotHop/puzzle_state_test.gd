extends GdUnitTestSuite
class_name PuzzleStateTest


func build_state(puzzle: Array) -> PuzzleState:
	return PuzzleState.new(PuzzleDef.parse(puzzle))

## basic state updates

func test_state_mark_dotted() -> void:
	var state := build_state(["o"])
	assert_that(state.get_grid_row_objs(0)).is_equal([[GameDef.Obj.Dot]])
	state.mark_dotted(Vector2(0,0))
	assert_that(state.get_grid_row_objs(0)).is_equal([[GameDef.Obj.Dotted]])

func test_state_mark_undotted() -> void:
	# ideally we could test without the player node...this kind of mark-undotted should be impossible
	var state := build_state(["x"])
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dotted, GameDef.Obj.Player])
	state.mark_undotted(Vector2(0,0))
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dot, GameDef.Obj.Player])

func test_state_mark_undo() -> void:
	var state := build_state(["o"])
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dot])
	state.mark_undo(Vector2(0,0))
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dot, GameDef.Obj.Undo])

	# should not add multiple "undo"
	state.mark_undo(Vector2(0,0))
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dot, GameDef.Obj.Undo])

func test_state_drop_undo() -> void:
	var state := build_state(["o"])
	state.mark_undo(Vector2(0,0))
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dot, GameDef.Obj.Undo])
	state.drop_undo(Vector2(0,0))
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dot])

func test_state_mark_player() -> void:
	var state := build_state(["o"])
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dot])
	state.mark_player(Vector2(0,0))
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dot, GameDef.Obj.Player])

func test_state_drop_player() -> void:
	var state := build_state(["x"])
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dotted, GameDef.Obj.Player])
	state.drop_player(Vector2(0,0))
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dotted])

## check_moves

func test_check_moves() -> void:
	var state := build_state(["x"])
	var all_moves := state.check_all_moves()
	assert_that(all_moves[Vector2.RIGHT][0].type).is_equal(PuzzleState.MoveType.stuck)
	assert_that(all_moves[Vector2.LEFT][0].type).is_equal(PuzzleState.MoveType.stuck)
	assert_that(all_moves[Vector2.UP][0].type).is_equal(PuzzleState.MoveType.stuck)
	assert_that(all_moves[Vector2.DOWN][0].type).is_equal(PuzzleState.MoveType.stuck)

func test_check_move_move_to_dot() -> void:
	var state := build_state(["xo"])
	var moves := state.check_move(Vector2.RIGHT)
	assert_int(len(moves)).is_equal(1)
	assert_that(moves[0].type).is_equal(PuzzleState.MoveType.move_to_dot)

	state = build_state(["x", "o"])
	moves = state.check_move(Vector2.DOWN)
	assert_int(len(moves)).is_equal(1)
	assert_that(moves[0].type).is_equal(PuzzleState.MoveType.move_to_dot)

	state = build_state(["ox"])
	moves = state.check_move(Vector2.LEFT)
	assert_int(len(moves)).is_equal(1)
	assert_that(moves[0].type).is_equal(PuzzleState.MoveType.move_to_dot)

	state = build_state(["o", "x"])
	moves = state.check_move(Vector2.UP)
	assert_int(len(moves)).is_equal(1)
	assert_that(moves[0].type).is_equal(PuzzleState.MoveType.move_to_dot)

func test_check_move_undo() -> void:
	var state := build_state(["xo"])
	var moves := state.check_move(Vector2.RIGHT)
	assert_int(len(moves)).is_equal(1)
	assert_that(moves[0].type).is_equal(PuzzleState.MoveType.move_to_dot)

	# hmmmm using apply_moves here.... ideally we could include an undo in the initial state to avoid this
	state.apply_moves(moves)

	moves = state.check_move(Vector2.LEFT)
	assert_int(len(moves)).is_equal(1)
	assert_that(moves[0].type).is_equal(PuzzleState.MoveType.undo)

func test_check_move_move_to_goal() -> void:
	var state := build_state(["xt"])
	var moves := state.check_move(Vector2.RIGHT)
	assert_int(len(moves)).is_equal(1)
	assert_that(moves[0].type).is_equal(PuzzleState.MoveType.move_to_goal)

func test_check_move_stuck() -> void:
	var state := build_state(["xo"])
	var moves := state.check_move(Vector2.LEFT)
	assert_int(len(moves)).is_equal(1)
	assert_that(moves[0].type).is_equal(PuzzleState.MoveType.stuck)

	moves = state.check_move(Vector2.UP)
	assert_int(len(moves)).is_equal(1)
	assert_that(moves[0].type).is_equal(PuzzleState.MoveType.stuck)

	moves = state.check_move(Vector2.DOWN)
	assert_int(len(moves)).is_equal(1)
	assert_that(moves[0].type).is_equal(PuzzleState.MoveType.stuck)

	state = build_state(["x", "o"])
	moves = state.check_move(Vector2.LEFT)
	assert_int(len(moves)).is_equal(1)
	assert_that(moves[0].type).is_equal(PuzzleState.MoveType.stuck)

	moves = state.check_move(Vector2.UP)
	assert_int(len(moves)).is_equal(1)
	assert_that(moves[0].type).is_equal(PuzzleState.MoveType.stuck)

	moves = state.check_move(Vector2.RIGHT)
	assert_int(len(moves)).is_equal(1)
	assert_that(moves[0].type).is_equal(PuzzleState.MoveType.stuck)

## apply_moves

func test_apply_moves_move_to_dot_and_undo() -> void:
	var state := build_state(["xo"])

	# initial state
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dotted, GameDef.Obj.Player])
	assert_array(state.get_grid_row_objs(0)[1]).contains_exactly_in_any_order([GameDef.Obj.Dot])
	# using check_move to build the move
	var moves := state.check_move(Vector2.RIGHT)
	assert_int(len(moves)).is_equal(1)
	assert_that(moves[0].type).is_equal(PuzzleState.MoveType.move_to_dot)
	var res := state.apply_moves(moves)
	assert_that(res).is_equal(PuzzleState.MoveResult.moved)
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dotted, GameDef.Obj.Undo])
	assert_array(state.get_grid_row_objs(0)[1]).contains_exactly_in_any_order([GameDef.Obj.Dotted, GameDef.Obj.Player])
	assert_bool(state.win).is_false()

	# undo
	moves = state.check_move(Vector2.LEFT)
	assert_int(len(moves)).is_equal(1)
	assert_that(moves[0].type).is_equal(PuzzleState.MoveType.undo)
	res = state.apply_moves(moves)
	assert_that(res).is_equal(PuzzleState.MoveResult.undo)
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dotted, GameDef.Obj.Player])
	assert_array(state.get_grid_row_objs(0)[1]).contains_exactly_in_any_order([GameDef.Obj.Dot])
	assert_bool(state.win).is_false()

func test_apply_moves_move_to_goal() -> void:
	var state := build_state(["xt"])

	# initial state
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dotted, GameDef.Obj.Player])
	assert_array(state.get_grid_row_objs(0)[1]).contains_exactly_in_any_order([GameDef.Obj.Goal])
	# using check_move to build the move
	var moves := state.check_move(Vector2.RIGHT)
	assert_int(len(moves)).is_equal(1)
	assert_that(moves[0].type).is_equal(PuzzleState.MoveType.move_to_goal)
	var res := state.apply_moves(moves)
	assert_that(res).is_equal(PuzzleState.MoveResult.moved)
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dotted, GameDef.Obj.Undo])
	assert_array(state.get_grid_row_objs(0)[1]).contains_exactly_in_any_order([GameDef.Obj.Goal, GameDef.Obj.Player])
	assert_bool(state.win).is_true()

func test_apply_moves_stuck() -> void:
	var state := build_state(["x."])

	# initial state
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dotted, GameDef.Obj.Player])
	assert_array(state.get_grid_row_objs(0)[1]).is_equal([])
	# using check_move to build the move
	var moves := state.check_move(Vector2.RIGHT)
	assert_int(len(moves)).is_equal(1)
	assert_that(moves[0].type).is_equal(PuzzleState.MoveType.stuck)
	var res := state.apply_moves(moves)
	assert_that(res).is_equal(PuzzleState.MoveResult.stuck)
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dotted, GameDef.Obj.Player])
	assert_array(state.get_grid_row_objs(0)[1]).is_equal([])
	assert_bool(state.win).is_false()

func test_apply_moves_signal() -> void:
	# TODO ensure expected cell and player callables are fired
	pass


## possible next moves

func test_possible_moves_basic_dot() -> void:
	var state := build_state(["xo"])
	var possible_move_coords := state.possible_move_cells.map(func(c: PuzzleState.Cell) -> Vector2: return c.coord)
	assert_array(possible_move_coords).contains_exactly_in_any_order([Vector2(1, 0)])

func test_possible_moves_basic_goal() -> void:
	var state := build_state(["xt"])
	var possible_move_coords := state.possible_move_cells.map(func(c: PuzzleState.Cell) -> Vector2: return c.coord)
	assert_array(possible_move_coords).contains_exactly_in_any_order([Vector2(1, 0)])

func test_possible_moves_multiple() -> void:
	var state := build_state([
		"xo",
		"o.",
		])
	var possible_move_coords := state.possible_move_cells.map(func(c: PuzzleState.Cell) -> Vector2: return c.coord)
	assert_array(possible_move_coords).contains_exactly_in_any_order([Vector2(1, 0), Vector2(0, 1)])

func test_possible_moves_updates_and_undo() -> void:
	var state := build_state(["xoo"])
	state.move(Vector2.RIGHT)
	var possible_move_coords := state.possible_move_cells.map(func(c: PuzzleState.Cell) -> Vector2: return c.coord)
	assert_array(possible_move_coords).contains_exactly_in_any_order([Vector2.ZERO, Vector2(2, 0)])

func test_possible_moves_updates_and_undo_more_complex() -> void:
	var state := build_state([
		"txo",
		"o.o",
		])

	state.move(Vector2.RIGHT)
	state.move(Vector2.DOWN)
	state.move(Vector2.LEFT)

	var possible_move_coords := state.possible_move_cells.map(func(c: PuzzleState.Cell) -> Vector2: return c.coord)
	assert_array(possible_move_coords).contains_exactly_in_any_order([Vector2.ZERO, Vector2(2, 1)])

func test_reemit_possible_move_signals() -> void:
	# TODO test cell-fired signals are emitted
	pass


## full movement tests

func test_move_right() -> void:
	var state := build_state(["xo"])

	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Player, GameDef.Obj.Dotted])
	assert_array(state.get_grid_row_objs(0)[1]).contains_exactly_in_any_order([GameDef.Obj.Dot])
	state.move(Vector2.RIGHT)
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dotted, GameDef.Obj.Undo])
	assert_array(state.get_grid_row_objs(0)[1]).contains_exactly_in_any_order([GameDef.Obj.Player, GameDef.Obj.Dotted])

func test_move_and_undo() -> void:
	var state := build_state(["xo"])

	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Player, GameDef.Obj.Dotted])
	assert_array(state.get_grid_row_objs(0)[1]).contains_exactly_in_any_order([GameDef.Obj.Dot])
	state.move(Vector2.RIGHT)
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dotted, GameDef.Obj.Undo])
	assert_array(state.get_grid_row_objs(0)[1]).contains_exactly_in_any_order([GameDef.Obj.Player, GameDef.Obj.Dotted])

	state.move(Vector2.LEFT)
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Player, GameDef.Obj.Dotted])
	assert_array(state.get_grid_row_objs(0)[1]).contains_exactly_in_any_order([GameDef.Obj.Dot])

func test_move_hopped_a_dot() -> void:
	var state := build_state([
		"oxot",
		"o.o.",
		])

	state.move(Vector2.RIGHT)
	state.move(Vector2.DOWN)
	state.move(Vector2.LEFT)
	state.move(Vector2.UP)

	var moves := state.check_move(Vector2.RIGHT)
	assert_int(len(moves)).is_equal(1)
	assert_that(moves[0].type).is_equal(PuzzleState.MoveType.move_to_goal)
	assert_int(len(moves[0].hopped_cells)).is_equal(2)
	assert_array(moves[0].hopped_cells.map(
		func(c: PuzzleState.Cell) -> Vector2: return c.coord))\
		.contains_exactly_in_any_order([Vector2(1, 0), Vector2(2, 0)])

	var res := state.apply_moves(moves)
	assert_that(res).is_equal(PuzzleState.MoveResult.moved)
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dotted, GameDef.Obj.Undo])
	assert_array(state.get_grid_row_objs(0)[1]).contains_exactly_in_any_order([GameDef.Obj.Dotted])
	assert_array(state.get_grid_row_objs(0)[2]).contains_exactly_in_any_order([GameDef.Obj.Dotted])
	assert_array(state.get_grid_row_objs(0)[3]).contains_exactly_in_any_order([GameDef.Obj.Goal, GameDef.Obj.Player])
	assert_bool(state.win).is_true()


## full puzzle tests

func test_basic_state_win() -> void:
	var state := build_state(["xoot"])

	assert_that(state.get_grid_row_objs(0)).is_equal(
		[[GameDef.Obj.Player, GameDef.Obj.Dotted], [GameDef.Obj.Dot], [GameDef.Obj.Dot], [GameDef.Obj.Goal]])
	assert_that(state.win).is_equal(false)
	state.move(Vector2.RIGHT)
	assert_that(state.get_grid_row_objs(0)).is_equal(
		[[GameDef.Obj.Dotted, GameDef.Obj.Undo], [GameDef.Obj.Player, GameDef.Obj.Dotted], [GameDef.Obj.Dot], [GameDef.Obj.Goal]])
	assert_that(state.win).is_equal(false)
	state.move(Vector2.RIGHT)
	assert_that(state.get_grid_row_objs(0)).is_equal(
		[[GameDef.Obj.Dotted], [GameDef.Obj.Dotted, GameDef.Obj.Undo], [GameDef.Obj.Player, GameDef.Obj.Dotted], [GameDef.Obj.Goal]])
	assert_that(state.win).is_equal(false)
	state.move(Vector2.RIGHT)
	assert_that(state.get_grid_row_objs(0)).is_equal(
		[[GameDef.Obj.Dotted], [GameDef.Obj.Dotted], [GameDef.Obj.Dotted, GameDef.Obj.Undo], [GameDef.Obj.Goal, GameDef.Obj.Player]])
	assert_bool(state.win).is_true()

func test_can_undo_across_dotted_cells() -> void:
	var state := build_state([
			"oooo.",
			"oxoot",
			"..oo.",
			])

	state.move(Vector2.RIGHT)
	state.move(Vector2.RIGHT)
	state.move(Vector2.UP)
	state.move(Vector2.LEFT)
	state.move(Vector2.LEFT)
	state.move(Vector2.LEFT)
	state.move(Vector2.DOWN)
	state.move(Vector2.RIGHT)

	assert_that(state.get_grid_row_objs(1)).is_equal(
		[[GameDef.Obj.Dotted, GameDef.Obj.Undo], [GameDef.Obj.Dotted], [GameDef.Obj.Dotted], [GameDef.Obj.Dotted], [GameDef.Obj.Goal, GameDef.Obj.Player]])
	assert_that(state.players[0].stuck).is_equal(true)

	state.move(Vector2.LEFT)

	assert_that(state.players[0].stuck).is_equal(false)
	assert_that(state.get_grid_row_objs(1)).is_equal(
		[[GameDef.Obj.Dotted, GameDef.Obj.Player], [GameDef.Obj.Dotted], [GameDef.Obj.Dotted], [GameDef.Obj.Dotted], [GameDef.Obj.Goal]])

func test_complex_two_player_test() -> void:
	var state := build_state([
			"....o.o",
			"tx..o.o",
			"......t",
			"oo.o.x.",
			"oo.o..o",
			])

	state.move(Vector2.RIGHT)
	state.move(Vector2.LEFT)
	state.move(Vector2.LEFT)
	state.move(Vector2.LEFT)
	state.move(Vector2.DOWN)
	state.move(Vector2.UP)
	state.move(Vector2.RIGHT)
	state.move(Vector2.RIGHT)
	state.move(Vector2.RIGHT)
	state.move(Vector2.UP)
	state.move(Vector2.DOWN)
	state.move(Vector2.LEFT)

	assert_bool(state.win).is_true()
	assert_array(state.get_grid_row_objs(1)[0]).contains_exactly_in_any_order([GameDef.Obj.Goal, GameDef.Obj.Player])
	assert_array(state.get_grid_row_objs(2)[6]).contains_exactly_in_any_order([GameDef.Obj.Goal, GameDef.Obj.Player])
