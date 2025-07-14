@tool
extends Object
class_name PuzzleState

## player

class Player:
	var coord: Vector2
	var stuck := false
	var move_history: Array = []

	signal move_to_cell(c: Cell)
	signal undo_to_cell(c: Cell)
	signal undo_to_same_cell(c: Cell)
	signal move_attempt_stuck(dir: Vector2)

	func _init(crd: Vector2) -> void:
		coord = crd

	func to_pretty() -> Variant:
		return ["P", coord, stuck, move_history]

	func previous_undo_coord(skip_coord: Vector2, start_at: int = 0) -> Variant:
		# pulls the first coord from player history that does not match `skip_coord`,
		# starting after `start_at`
		for m: Vector2 in move_history.slice(start_at):
			if m != skip_coord:
				return m
		return


## cell

class Cell:
	var objs: Array[GameDef.Obj]
	var coord: Vector2

	signal mark_dotted
	signal mark_undotted

	func _init(_coord: Vector2, _objs: Array[GameDef.Obj]) -> void:
		coord = _coord
		objs = _objs

	func to_pretty() -> Variant:
		return [coord, objs]

	func has_player() -> bool:
		return GameDef.Obj.Player in objs
	func has_dot() -> bool:
		return GameDef.Obj.Dot in objs
	func has_dotted() -> bool:
		return GameDef.Obj.Dotted in objs
	func has_dot_or_dotted() -> bool:
		return has_dot() or has_dotted()
	func has_goal() -> bool:
		return GameDef.Obj.Goal in objs
	func has_dot_or_dotted_or_goal() -> bool:
		return has_dot_or_dotted() or has_goal()
	func has_undo() -> bool:
		return GameDef.Obj.Undo in objs


## move

class Move:
	var move_direction: Vector2
	var player: Player
	var type: MoveType
	var cell: Cell

	var hopped_cells: Array[Cell] = []

	func _init(dir: Vector2, p: Player) -> void:
		move_direction = dir
		type = MoveType.unknown
		player = p

	func to_pretty() -> Variant:
		return [type, player, cell]

	func mark_undo() -> void:
		type = MoveType.undo
	func mark_stuck() -> void:
		type = MoveType.stuck
	func mark_blocked_by_player() -> void:
		type = MoveType.blocked_by_player
	func move_to_dot(c: Cell) -> void:
		type = MoveType.move_to_dot
		cell = c
	func move_to_goal(c: Cell) -> void:
		type = MoveType.move_to_goal
		cell = c

	func add_dot_to_hop(c: Cell) -> void:
		hopped_cells.append(c)

enum MoveType {
	unknown=0,
	stuck=1,
	blocked_by_player=2,
	move_to_dot=3,
	move_to_goal=4,
	undo=5,
	}

enum MoveResult {
	zero=0,
	move_not_allowed=1,
	stuck=2, # no legal destination in direction
	undo=3,
	moved=4,
	}

## state vars

var puzzle_def: PuzzleDef
var game_def: GameDef
var win := false
var grid_width: int
var grid_height: int

var players: Array[Player] = []
var cells_by_coord: Dictionary[Vector2, Cell] = {}

## state

func to_pretty() -> Variant:
	var _grid: Array = []
	for row in range(grid_height):
		_grid.append(get_grid_row_objs(row))
	return {state="state", grid=_grid}

## init

func _init(puzz_def: PuzzleDef, g_def: GameDef) -> void:
	puzzle_def = puzz_def
	game_def = g_def

	for cell: GameDef.GridCell in game_def.grid_cells(puzzle_def):
		var coord := Vector2(cell.coord.x, cell.coord.y)
		cells_by_coord[coord] = Cell.new(coord, cell.objs)

		if cells_by_coord[coord].has_player():
			players.append(Player.new(coord))

	grid_width = len(puzzle_def.shape[0])
	grid_height = len(puzzle_def.shape)

## getters

func get_grid_row_objs(row: int) -> Array:
	var row_objs: Array = []
	for x in range(grid_width):
		var cell: Cell = cells_by_coord[Vector2(x, row)]
		row_objs.append(cell.objs)
	return row_objs

func all_cells() -> Array[Cell]:
	return cells_by_coord.values()

# Returns a list of cell-object-arrays (an array per cell)
func all_cell_objs() -> Array:
	var cs: Array = []
	for cell: Cell in cells_by_coord.values():
		cs.append(cell.objs)
	return cs

func dot_count(only_undotted: bool = false) -> int:
	return len(all_cells().filter(func(c: Cell) -> bool:
		if only_undotted and c.has_dot():
			return true
		elif not only_undotted and c.has_dot_or_dotted():
			return true
		return false))

## predicates

func check_win() -> bool:
	return all_dotted() and all_players_at_goal()

# Returns true if there are no "dot" objects in the state grid
func all_dotted() -> bool:
	return all_cells().all(func(c: Cell) -> bool: return not c.has_dot())

func all_players_at_goal() -> bool:
	return all_cells()\
		.filter(func(c: Cell) -> bool: return c.has_goal())\
		.all(func(c: Cell) -> bool: return c.has_player())

## grid helpers

# returns true if the passed coord is in the level's grid
func coord_in_grid(coord: Vector2) -> bool:
	return coord.x >= 0 and coord.y >= 0 and \
		coord.x < grid_width and coord.y < grid_height

func cell_at_coord(coord: Vector2) -> Cell:
	return cells_by_coord.get(coord)

# returns a list of cells from the passed position in the passed direction
# the cells are dicts with a coord, a list of objs (string names), and a list of nodes
func cells_in_direction(coord: Vector2, dir: Vector2) -> Array:
	if dir == Vector2.ZERO:
		return []
	var cells: Array = []
	var cursor: Vector2 = coord + dir
	var last_cursor: Variant = null
	while coord_in_grid(cursor) and last_cursor != cursor:
		cells.append(cell_at_coord(cursor))
		last_cursor = cursor
		cursor += dir
	return cells


## grid cell updates
# these should probably live on the Cell class

func mark_dotted(coord: Vector2) -> void:
	cells_by_coord[coord].objs.erase(GameDef.Obj.Dot)
	cells_by_coord[coord].objs.append(GameDef.Obj.Dotted)

func mark_undotted(coord: Vector2) -> void:
	cells_by_coord[coord].objs.erase(GameDef.Obj.Dotted)
	cells_by_coord[coord].objs.append(GameDef.Obj.Dot)

func mark_undo(coord: Vector2) -> void:
	if not cells_by_coord[coord].has_undo():
		cells_by_coord[coord].objs.append(GameDef.Obj.Undo)

func drop_undo(coord: Vector2) -> void:
	cells_by_coord[coord].objs.erase(GameDef.Obj.Undo)

func mark_player(coord: Vector2) -> void:
	cells_by_coord[coord].objs.append(GameDef.Obj.Player)

func drop_player(coord: Vector2) -> void:
	cells_by_coord[coord].objs.erase(GameDef.Obj.Player)

##################################################################
# public state updates

#############################
## check_moves

func check_move(move_dir: Vector2) -> Array[Move]:
	var moves_to_make: Array[Move] = []
	for p: Player in players:
		var mv: Move = Move.new(move_dir, p)
		var cells: Array = cells_in_direction(p.coord, move_dir)
		if len(cells) == 0:
			mv.mark_stuck()
			moves_to_make.append(mv)
			continue

		# drop empty cells
		cells = cells.filter(func(c: Cell) -> bool: return len(c.objs) > 0)
		if len(cells) == 0:
			mv.mark_stuck()
			moves_to_make.append(mv)
			continue

		# check for _any_ undo cells first
		var undo_cell_in_dir: Variant = U.first(cells.filter(func(c: Cell) -> bool:
			return c.has_undo() and c.coord in p.move_history))

		if undo_cell_in_dir != null:
			mv.mark_undo()
		else:
			for cell: Cell in cells:
				if p.stuck:
					# Log.warn("stuck, didn't see an undo in dir", move_dir, p.move_history)
					mv.mark_stuck()
					break
				if cell.has_player():
					mv.mark_blocked_by_player()
					# moving toward player animation?
					break
				if cell.has_dotted():
					mv.add_dot_to_hop(cell)
					continue
				if cell.has_dot():
					mv.move_to_dot(cell)
					break
				if cell.has_goal():
					mv.move_to_goal(cell)
					break
				Log.warn("unexpected/unhandled cell in direction", cell)
		moves_to_make.append(mv)

	# if no moves to make, maybe we want to add a stuck move
	return moves_to_make

func check_all_moves() -> Dictionary:
	var moves: Dictionary = {}
	for dir: Vector2 in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		moves[dir] = check_move(dir)
	return moves

#############################
## apply_moves helpers

# Move the player to the passed cell's coordinate.
# also updates the game state
# cell should have a `coord`
func move_player_to_cell(player: Player, cell: Cell) -> void:
	player.move_history.push_front(player.coord)

	# move the player node
	player.move_to_cell.emit(cell)

	# update game state
	mark_player(cell.coord)
	drop_player(player.coord)

	# remove previous undo marker
	# NOTE start_at 1 b/c history has already been updated
	var prev_undo_coord: Variant
	if len(player.move_history) > 1:
		prev_undo_coord = player.previous_undo_coord(player.coord, 1)
	if prev_undo_coord != null:
		drop_undo(prev_undo_coord as Vector2)

	# add new undo marker at current coord
	mark_undo(player.coord)

	# update to new coord
	player.coord = cell.coord

# converts the dot at the cell's coord to a dotted one
# depends on cell for `coord` and `nodes`.
func mark_cell_dotted(cell: Cell) -> void:
	# update game state
	mark_dotted(cell.coord)
	cell.mark_dotted.emit()

# converts dotted back to dot (undo)
# depends on cell for `coord` and `nodes`.
func mark_cell_undotted(cell: Cell) -> void:
	# update game state
	mark_undotted(cell.coord)
	cell.mark_undotted.emit()

## move to dot ##############################################################

func move_to_dot(player: Player, cell: Cell) -> void:
	# consider handling these in the same step (depending on the animation)
	move_player_to_cell(player, cell)
	mark_cell_dotted(cell)

## move to goal ##############################################################

func move_to_goal(player: Player, cell: Cell) -> void:
	move_player_to_cell(player, cell)

	if check_win():
		win = true
	else:
		player.stuck = true

## undo last move ##############################################################

func undo_last_move(player: Player) -> void:
	# supports the solver - undo moves state.win back to false
	win = false

	if len(player.move_history) == 0:
		Log.warn("Can't undo, no moves yet!")
		return

	# remove last move from move_history
	var last_pos: Vector2 = player.move_history.pop_front()
	var current_cell: Cell = cell_at_coord(player.coord)
	var dest_cell: Cell = cell_at_coord(last_pos)

	# need to walk back the grid's Undo markers
	var pos_before_last: Variant = player.previous_undo_coord(dest_cell.coord, 0)
	if pos_before_last != null:
		mark_undo(pos_before_last as Vector2)
	drop_undo(dest_cell.coord)

	if last_pos == player.coord:
		# occurs in multi-hopper puzzles ('other' player stays in same place when undoing)
		player.undo_to_same_cell.emit(dest_cell)
		return

	# move player node
	player.undo_to_cell.emit(dest_cell)

	# update game state
	mark_player(dest_cell.coord)
	drop_player(player.coord)

	if current_cell.has_dotted():
		# restore dot at the current player position
		mark_cell_undotted(current_cell)
	if current_cell.has_goal():
		# unstuck when undoing from the goal
		player.stuck = false

	# update state player position
	player.coord = dest_cell.coord

#############################
## apply_moves

# TODO multi-hopper unit test for undo + new hop
func apply_moves(moves_to_make: Array[Move]) -> MoveResult:
	# TODO what moves should be applied in different game modes?
	# maybe there are player types that move or don't move on undo?
	# or maybe undo or move always overwrites?

	# var reses : Array[MoveResult] = []
	# for m: Move in moves_to_make:
	# 	if m.type == MoveType.move_to_dot:
	# 		# TODO consider influencing with any Move.dots-to-hop
	# 		move_to_dot(m.player, m.cell)
	# 		reses.append(MoveResult.moved)
	# 	if m.type == MoveType.move_to_goal:
	# 		# TODO consider influencing with any Move.dots-to-hop
	# 		move_to_goal(m.player, m.cell)
	# 		reses.append(MoveResult.moved)
	# 	if m.type == MoveType.undo:
	# 		undo_last_move(m.player)
	# 		reses.append(MoveResult.undo)
	# 	if m.type == MoveType.stuck:
	# 		m.player.move_attempt_stuck.emit(m.move_direction)
	# 		reses.append(MoveResult.stuck)
	# 	if m.type == MoveType.hop_a_dot:
	# 		# reusing the stuck behavior here
	# 		m.player.move_attempt_stuck.emit(m.move_direction)
	# 		reses.append(MoveResult.stuck)
	# # return reses
	# return reses[0]

	var any_move: bool = moves_to_make.any(func(m: Move) -> bool:
		return m.type in [MoveType.move_to_dot, MoveType.move_to_goal])
	if any_move:
		for m: Move in moves_to_make:
			# TODO consider influencing these moves with any Move.dots-to-hop
			if m.type == MoveType.move_to_dot:
				move_to_dot(m.player, m.cell)
			if m.type == MoveType.move_to_goal:
				move_to_goal(m.player, m.cell)

		return MoveResult.moved

	var any_undo: bool = moves_to_make.any(func(m: Move) -> bool: return m.type == MoveType.undo)
	if any_undo:
		for m: Move in moves_to_make:
			if m.type == MoveType.undo:
				undo_last_move(m.player)

		return MoveResult.undo

	var any_stuck: bool = moves_to_make.any(func(m: Move) -> bool:
		return m.type in [MoveType.stuck])
	if any_stuck:
		for m: Move in moves_to_make:
			if m.type == MoveType.stuck:
				m.player.move_attempt_stuck.emit(m.move_direction)
			# TODO restore! was reusing the stuck animation here when moving toward hopped dots
			# if m.type == MoveType.hop_a_dot:
			# 	m.player.move_attempt_stuck.emit(m.move_direction)

	return MoveResult.stuck

## move ##############################################################

func move(move_dir: Vector2) -> MoveResult:
	if move_dir == Vector2.ZERO:
		# don't do anything!
		return MoveResult.zero

	var moves_to_make := check_move(move_dir)
	# Log.prn("moves to make", moves_to_make)
	return apply_moves(moves_to_make)
