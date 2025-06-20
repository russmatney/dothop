@tool
extends Object
class_name PuzzleState

## player

class Player:
	var coord: Vector2
	var stuck := false
	var move_history: Array = []
	var node: DotHopPlayer

	func _init(crd: Vector2, nd: DotHopPlayer = null) -> void:
		coord = crd
		node = nd

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
	var nodes: Array[DotHopDot]

	func _init(_coord: Vector2, _objs: Array[GameDef.Obj], _nodes: Array[DotHopDot]) -> void:
		coord = _coord
		objs = _objs
		nodes = _nodes

	func to_pretty() -> Variant:
		return [coord, objs, nodes]

	func has_player() -> bool:
		return GameDef.Obj.Player in objs
	func has_dot() -> bool:
		return GameDef.Obj.Dot in objs
	func has_dotted() -> bool:
		return GameDef.Obj.Dotted in objs
	func has_goal() -> bool:
		return GameDef.Obj.Goal in objs
	func has_undo() -> bool:
		return GameDef.Obj.Undo in objs


## move

class Move:
	var move_direction: Vector2
	var player: Player
	var type: MoveType
	var cell: Cell

	func _init(dir: Vector2, t: MoveType, p: Player, c: Cell = null) -> void:
		move_direction = dir
		type = t
		player = p
		cell = c

	func to_pretty() -> Variant:
		return [type, player, cell]

	static func undo(dir: Vector2, p: Player) -> Move:
		return Move.new(dir, MoveType.undo, p)
	static func stuck(dir: Vector2, p: Player) -> Move:
		return Move.new(dir, MoveType.stuck, p)
	static func blocked_by_player(dir: Vector2, p: Player) -> Move:
		return Move.new(dir, MoveType.blocked_by_player, p)
	static func move_to_dot(dir: Vector2, p: Player, c: Cell) -> Move:
		return Move.new(dir, MoveType.move_to_dot, p, c)
	static func move_to_goal(dir: Vector2, p: Player, c: Cell) -> Move:
		return Move.new(dir, MoveType.move_to_goal, p, c)
	static func hop_a_dot(dir: Vector2, p: Player, c: Cell) -> Move:
		return Move.new(dir, MoveType.hop_a_dot, p, c)

enum MoveType {
	undo=0,
	stuck=1,
	blocked_by_player=2,
	move_to_dot=3,
	move_to_goal=4,
	hop_a_dot=5,
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
var players: Array[Player] = []
var grid_xs: int
var grid_ys: int
# var nodes_by_coord: Dictionary[Vector2, Array[DotHopNode]] = {} # just the nodes
var nodes_by_coord: Dictionary = {} # just the nodes
var cells_by_coord: Dictionary[Vector2, Cell] = {}

## state

func to_pretty() -> Variant:
	var _grid: Array = []
	for row in range(grid_ys):
		_grid.append(get_grid_row_objs(row))
	return {state="state", grid=_grid}

## init

func _init(puzz_def: PuzzleDef, g_def: GameDef) -> void:
	puzzle_def = puzz_def
	game_def = g_def

	for cell: GameDef.GridCell in game_def.grid_cells(puzzle_def):
		var coord := Vector2(cell.coord.x, cell.coord.y)
		cells_by_coord[coord] = Cell.new(coord, cell.objs, [])

		if GameDef.Obj.Player in cell.objs:
			players.append(Player.new(coord))

	grid_xs = len(puzzle_def.shape[0])
	grid_ys = len(puzzle_def.shape)

## state updates

# TODO rename to 'set-player-node' or some such
func add_player(coord: Vector2, node: DotHopPlayer) -> void:
	for p: Player in players:
		if p.coord == coord:
			p.node = node

# TODO drop this?
func add_dot(coord: Vector2, node: Node2D) -> void:
	if not coord in nodes_by_coord:
		nodes_by_coord[coord] = []
	(nodes_by_coord[coord] as Array).append(node)

func set_nodes(cell: Cell, nodes: Array[DotHopDot]) -> void:
	cells_by_coord[cell.coord].nodes = nodes

## getters

func get_grid_row_objs(row: int) -> Array:
	var row_objs: Array = []
	for x in range(grid_xs):
		var cell: Cell = cells_by_coord[Vector2(x, row)]
		row_objs.append(cell.objs)
	return row_objs

func coord_for_dot(dot: DotHopDot) -> Vector2:
	for coord: Vector2 in nodes_by_coord:
		if dot in nodes_by_coord[coord]:
			return coord
	return Vector2.ZERO

func all_coords() -> Array[Vector2]:
	return cells_by_coord.keys()

func all_cells() -> Array[Cell]:
	return cells_by_coord.values()

func objs_for_coord(coord: Vector2) -> Array[GameDef.Obj]:
	return cells_by_coord[coord].objs

# Returns a list of cell-object-arrays (per cell)
func all_cell_objs() -> Array:
	var cs: Array = []
	for cell: Cell in cells_by_coord.values():
		cs.append(cell.objs)
	return cs

func all_cell_nodes(opts: Dictionary = {}) -> Array[Node2D]:
	var ns: Array = nodes_by_coord.values().reduce(func(agg: Array, nodes: Array) -> Array:
		if "filter" in opts:
			var f: Callable = opts.get("filter")
			nodes = nodes.filter(f)
		agg.append_array(nodes)
		return agg, []) # if we don't provide an initial val, the first node gets through FOR FREE
	var t_nodes: Array[Node2D] = []
	t_nodes.assign(ns)
	return t_nodes

func dot_count(only_undotted: bool = false) -> int:
	return len(all_cell_objs().filter(func(c: Array[GameDef.Obj]) -> bool:
		for obj_type: GameDef.Obj in c:
			if only_undotted and obj_type in [GameDef.Obj.Dot]:
				return true
			elif not only_undotted and obj_type in [GameDef.Obj.Dot, GameDef.Obj.Dotted]:
				return true
		return false))

## predicates

func check_win() -> bool:
	return all_dotted() and all_players_at_goal()

# Returns true if there are no "dot" objects in the state grid
func all_dotted() -> bool:
	return all_cell_objs().all(func(objs: Array[GameDef.Obj]) -> bool:
		if GameDef.Obj.Dot in objs:
			return false
		return true)

func all_players_at_goal() -> bool:
	return all_cell_objs().filter(func(c: Array[GameDef.Obj]) -> bool:
		return GameDef.Obj.Goal in c
		).all(func(c: Array[GameDef.Obj]) -> bool:
			return GameDef.Obj.Player in c)

func is_coord_dotted(coord: Vector2) -> bool:
	return GameDef.Obj.Dotted in cells_by_coord[coord].objs

func is_coord_goal(coord: Vector2) -> bool:
	return GameDef.Obj.Goal in cells_by_coord[coord].objs

## grid helpers

# returns true if the passed coord is in the level's grid
func coord_in_grid(coord: Vector2) -> bool:
	return coord.x >= 0 and coord.y >= 0 and \
		coord.x < grid_xs and coord.y < grid_ys

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
		var cells: Array = cells_in_direction(p.coord, move_dir)
		if len(cells) == 0:
			moves_to_make.append(Move.stuck(move_dir, p))
			continue

		cells = cells.filter(func(c: Cell) -> bool: return len(c.objs) > 0)
		if len(cells) == 0:
			moves_to_make.append(Move.stuck(move_dir, p))
			continue

		# instead of markers, read undo based on only the player move history?
		var undo_cell_in_dir: Variant = U.first(cells.filter(func(c: Cell) -> bool:
			return c.has_undo() and c.coord in p.move_history))

		if undo_cell_in_dir != null:
			moves_to_make.append(Move.undo(move_dir, p))
		else:
			for cell: Cell in cells:
				if p.stuck:
					# Log.warn("stuck, didn't see an undo in dir", move_dir, p.move_history)
					moves_to_make.append(Move.stuck(move_dir, p))
					break
				if cell.has_player():
					moves_to_make.append(Move.blocked_by_player(move_dir, p))
					# moving toward player animation?
					break
				if cell.has_dotted():
					moves_to_make.append(Move.hop_a_dot(move_dir, p, cell))
					continue
				if cell.has_dot():
					moves_to_make.append(Move.move_to_dot(move_dir, p, cell))
					break
				if cell.has_goal():
					moves_to_make.append(Move.move_to_goal(move_dir, p, cell))
					break
				Log.warn("unexpected/unhandled cell in direction", cell)

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
# NOTE updating move_history is done after all players move
func move_player_to_cell(player: PuzzleState.Player, cell: PuzzleState.Cell) -> Signal:
	# move player node
	var move_finished_sig: Signal
	if player.node != null:
		var res: Variant = player.node.move_to_coord(cell.coord)
		if res != null:
			move_finished_sig = res

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

	return move_finished_sig

# converts the dot at the cell's coord to a dotted one
# depends on cell for `coord` and `nodes`.
func mark_cell_dotted(cell: PuzzleState.Cell) -> void:
	# update game state
	mark_dotted(cell.coord)
	# support multiple nodes per cell?
	var node: DotHopDot = U.first(cell.nodes)
	if node == null:
		# Log.warn("can't mark dotted, no node found!", cell)
		return
	node.mark_dotted()

# converts dotted back to dot (undo)
# depends on cell for `coord` and `nodes`.
func mark_cell_undotted(cell: PuzzleState.Cell) -> void:
	# update game state
	mark_undotted(cell.coord)
	# support multiple nodes per cell?
	var node: DotHopDot = U.first(cell.nodes)
	if node == null:
		# undoing from goal doesn't require any undotting
		return
	node.mark_undotted()

## move to dot ##############################################################

func move_to_dot(player: PuzzleState.Player, cell: PuzzleState.Cell) -> void:
	# consider handling these in the same step (depending on the animation)
	move_player_to_cell(player, cell)
	mark_cell_dotted(cell)

## move to goal ##############################################################

func move_to_goal(player: PuzzleState.Player, cell: PuzzleState.Cell) -> Signal:
	var move_finished: Signal = move_player_to_cell(player, cell)

	if check_win():
		win = true
		return move_finished
	else:
		player.stuck = true
		return move_finished

## undo last move ##############################################################

func undo_last_move(player: PuzzleState.Player) -> void:
	# supports the solver - undo moves state.win back to false
	win = false

	if len(player.move_history) == 0:
		Log.warn("Can't undo, no moves yet!")
		return
	# remove last move from move_history
	var last_pos: Vector2 = player.move_history.pop_front()
	var dest_cell: PuzzleState.Cell = cell_at_coord(last_pos)

	# need to walk back the grid's Undo markers
	var pos_before_last: Variant = player.previous_undo_coord(dest_cell.coord, 0)
	if pos_before_last != null:
		mark_undo(pos_before_last as Vector2)
	drop_undo(dest_cell.coord)

	if last_pos == player.coord:
		# used in multi-hopper puzzles ('other' player stays in same place when undoing)

		if player.node != null:
			player.node.undo_to_same_coord()
		return

	# move player node
	if player.node != null:
		player.node.undo_to_coord(dest_cell.coord)

	# update game state
	mark_player(dest_cell.coord)
	drop_player(player.coord)

	if is_coord_dotted(player.coord):
		# restore dot at the current player position
		mark_cell_undotted(cell_at_coord(player.coord))
	if is_coord_goal(player.coord):
		# unstuck when undoing from the goal
		player.stuck = false

	# update state player position
	player.coord = dest_cell.coord

#############################
## apply_moves

func apply_moves(moves_to_make: Array[Move]) -> MoveResult:
	var any_move: bool = moves_to_make.any(func(m: Move) -> bool:
		return m.type in [MoveType.move_to_dot, MoveType.move_to_goal])
	if any_move:
		for p: Player in players:
			p.move_history.push_front(p.coord)

		for m: Move in moves_to_make:
			# TODO consider influencing these moves with any Move.dots-to-hop

			if m.type == MoveType.move_to_dot:
				move_to_dot(m.player, m.cell)
			if m.type == MoveType.move_to_goal:
				move_to_goal(m.player, m.cell)

		return MoveResult.moved

	var any_undo: bool = moves_to_make.any(func(m: Move) -> bool: return m.type == MoveType.undo)
	if any_undo:
		# consider only undoing ONE time? does it make a difference?
		for m: Move in moves_to_make:
			if m.type == MoveType.undo:
				undo_last_move(m.player)

		# exit early for undos
		return MoveResult.undo

	var any_stuck: bool = moves_to_make.any(func(m: Move) -> bool:
		return m.type in [MoveType.stuck, MoveType.hop_a_dot])
	if any_stuck:
		for m: Move in moves_to_make:
			if m.type == MoveType.stuck:
				if m.player.node != null:
					m.player.node.move_attempt_stuck(m.move_direction)
			if m.type == MoveType.hop_a_dot:
				# reusing the stuck behavior here
				if m.player.node != null:
					m.player.node.move_attempt_stuck(m.move_direction)

	return MoveResult.stuck


## move ##############################################################

func move(move_dir: Vector2) -> PuzzleState.MoveResult:
	if move_dir == Vector2.ZERO:
		# don't do anything!
		return PuzzleState.MoveResult.zero

	var moves_to_make := check_move(move_dir)
	# Log.prn("moves to make", moves_to_make)
	return apply_moves(moves_to_make)
