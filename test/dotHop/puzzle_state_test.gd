extends GdUnitTestSuite
class_name PuzzleStateTest


func build_state(puzzle: Array) -> PuzzleState:
	var game_def := GameDef.from_puzzle(puzzle)
	return PuzzleState.new(game_def.puzzles[0], game_def)

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

# func test_check_move_undo() -> void:
# 	# TODO support 'u' in the legend an undo
# 	# TODO support 'dotted' in the legend an undo
# 	var state := build_state(["xu"])
# 	var moves := state.check_move(Vector2.RIGHT)
# 	assert_int(len(moves)).is_equal(1)
# 	assert_that(moves[0].type).is_equal(PuzzleState.MoveType.undo)

## apply_moves

func test_apply_moves_move_to_dot() -> void:
	var state := build_state(["xo"])

	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dotted, GameDef.Obj.Player])
	assert_array(state.get_grid_row_objs(0)[1]).contains_exactly_in_any_order([GameDef.Obj.Dot])
	var moves := state.check_move(Vector2.RIGHT)
	assert_int(len(moves)).is_equal(1)
	assert_that(moves[0].type).is_equal(PuzzleState.MoveType.move_to_dot)
	var res := state.apply_moves(moves)
	assert_that(res).is_equal(PuzzleState.MoveResult.moved)
	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dotted, GameDef.Obj.Undo])
	assert_array(state.get_grid_row_objs(0)[1]).contains_exactly_in_any_order([GameDef.Obj.Dotted, GameDef.Obj.Player])

## full movement tests

# func test_move_once() -> void:
# 	var state := build_state(["xo"])

# 	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Player, GameDef.Obj.Dotted])
# 	assert_array(state.get_grid_row_objs(0)[1]).contains_exactly_in_any_order([GameDef.Obj.Dot])
# 	# state.move(Vector2.RIGHT)
# 	assert_array(state.get_grid_row_objs(0)[0]).contains_exactly_in_any_order([GameDef.Obj.Dotted])
# 	assert_array(state.get_grid_row_objs(0)[1]).contains_exactly_in_any_order([GameDef.Obj.Player, GameDef.Obj.Dotted])

## full puzzle tests


# func test_basic_state_win() -> void:
# 	var state := build_state(["xoot"])

# 	assert_that(state.get_grid_row_objs(0)).is_equal(
# 		[[GameDef.Obj.Player, GameDef.Obj.Dotted], [GameDef.Obj.Dot], [GameDef.Obj.Dot], [GameDef.Obj.Goal]])
# 	assert_that(state.win).is_equal(false)
# 	# state.move(Vector2.RIGHT)
# 	assert_that(state.get_grid_row_objs(0)).is_equal(
# 		[[GameDef.Obj.Dotted, GameDef.Obj.Undo], [GameDef.Obj.Player, GameDef.Obj.Dotted], [GameDef.Obj.Dot], [GameDef.Obj.Goal]])
# 	assert_that(state.win).is_equal(false)
# 	# state.move(Vector2.RIGHT)
# 	assert_that(state.get_grid_row_objs(0)).is_equal(
# 		[[GameDef.Obj.Dotted], [GameDef.Obj.Dotted, GameDef.Obj.Undo], [GameDef.Obj.Player, GameDef.Obj.Dotted], [GameDef.Obj.Goal]])
# 	assert_that(state.win).is_equal(false)
# 	# state.move(Vector2.RIGHT)
# 	assert_that(state.get_grid_row_objs(0)).is_equal(
# 		[[GameDef.Obj.Dotted], [GameDef.Obj.Dotted], [GameDef.Obj.Dotted, GameDef.Obj.Undo], [GameDef.Obj.Goal, GameDef.Obj.Player]])
# 	assert_that(state.win).is_equal(true)

# 	state.free()
