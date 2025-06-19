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

func test_check_move_move_to_dot() -> void:
	var state := build_state(["xo"])
	var moves := state.check_move(Vector2.RIGHT)
	var move_types := moves.map(func(m: PuzzleState.Move) -> PuzzleState.MoveType: return m.type)
	assert_array(move_types).contains_exactly_in_any_order([PuzzleState.MoveType.move_to_dot])

	state = build_state(["x", "o"])
	moves = state.check_move(Vector2.DOWN)
	move_types = moves.map(func(m: PuzzleState.Move) -> PuzzleState.MoveType: return m.type)
	assert_array(move_types).contains_exactly_in_any_order([PuzzleState.MoveType.move_to_dot])

	state = build_state(["ox"])
	moves = state.check_move(Vector2.LEFT)
	move_types = moves.map(func(m: PuzzleState.Move) -> PuzzleState.MoveType: return m.type)
	assert_array(move_types).contains_exactly_in_any_order([PuzzleState.MoveType.move_to_dot])

	state = build_state(["o", "x"])
	moves = state.check_move(Vector2.UP)
	move_types = moves.map(func(m: PuzzleState.Move) -> PuzzleState.MoveType: return m.type)
	assert_array(move_types).contains_exactly_in_any_order([PuzzleState.MoveType.move_to_dot])

func test_check_move_move_to_goal() -> void:
	var state := build_state(["xt"])
	var moves := state.check_move(Vector2.RIGHT)
	var move_types := moves.map(func(m: PuzzleState.Move) -> PuzzleState.MoveType: return m.type)
	assert_array(move_types).contains_exactly_in_any_order([PuzzleState.MoveType.move_to_goal])

func test_check_move_stuck() -> void:
	var state := build_state(["xo"])
	var moves := state.check_move(Vector2.LEFT)
	var move_types := moves.map(func(m: PuzzleState.Move) -> PuzzleState.MoveType: return m.type)
	assert_array(move_types).contains_exactly_in_any_order([PuzzleState.MoveType.stuck])

	moves = state.check_move(Vector2.UP)
	move_types = moves.map(func(m: PuzzleState.Move) -> PuzzleState.MoveType: return m.type)
	assert_array(move_types).contains_exactly_in_any_order([PuzzleState.MoveType.stuck])

	moves = state.check_move(Vector2.DOWN)
	move_types = moves.map(func(m: PuzzleState.Move) -> PuzzleState.MoveType: return m.type)
	assert_array(move_types).contains_exactly_in_any_order([PuzzleState.MoveType.stuck])

	state = build_state(["x", "o"])
	moves = state.check_move(Vector2.LEFT)
	move_types = moves.map(func(m: PuzzleState.Move) -> PuzzleState.MoveType: return m.type)
	assert_array(move_types).contains_exactly_in_any_order([PuzzleState.MoveType.stuck])

	moves = state.check_move(Vector2.UP)
	move_types = moves.map(func(m: PuzzleState.Move) -> PuzzleState.MoveType: return m.type)
	assert_array(move_types).contains_exactly_in_any_order([PuzzleState.MoveType.stuck])

	moves = state.check_move(Vector2.RIGHT)
	move_types = moves.map(func(m: PuzzleState.Move) -> PuzzleState.MoveType: return m.type)
	assert_array(move_types).contains_exactly_in_any_order([PuzzleState.MoveType.stuck])

## apply_moves

# func test_apply_moves_move_to_dot() -> void:
# 	pass

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
