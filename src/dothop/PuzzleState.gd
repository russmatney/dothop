@tool
extends Object
class_name PuzzleState

## player

class Player:
	var coord: Vector2
	var stuck := false
	var move_history: Array = []
	var node: DotHopPlayer

	func _init(crd: Vector2, nd: DotHopPlayer) -> void:
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


## move

class Move:
	enum MoveType {
		undo=0,
		stuck=1,
		blocked_by_player=2,
		move_to_dot=3,
		move_to_goal=4,
		hop_a_dot=5,
		}

	var player: PuzzleState.Player
	var type: MoveType
	var cell: PuzzleState.Cell

	func _init(t: MoveType, p: PuzzleState.Player, c: PuzzleState.Cell = null) -> void:
		type = t
		player = p
		cell = c

	func to_pretty() -> Variant:
		return [type, player, cell]

	static func undo(p: PuzzleState.Player) -> Move:
		return Move.new(MoveType.undo, p)
	static func stuck(p: PuzzleState.Player) -> Move:
		return Move.new(MoveType.stuck, p)
	static func blocked_by_player(p: PuzzleState.Player) -> Move:
		return Move.new(MoveType.blocked_by_player, p)
	static func move_to_dot(p: PuzzleState.Player, c: PuzzleState.Cell) -> Move:
		return Move.new(MoveType.move_to_dot, p, c)
	static func move_to_goal(p: PuzzleState.Player, c: PuzzleState.Cell) -> Move:
		return Move.new(MoveType.move_to_goal, p, c)
	static func hop_a_dot(p: PuzzleState.Player, c: PuzzleState.Cell) -> Move:
		return Move.new(MoveType.hop_a_dot, p, c)

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
var grid: Array
var grid_xs: int
var grid_ys: int
# var nodes_by_coord: Dictionary[Vector2, Array[DotHopNode]] = {} # just the nodes
var nodes_by_coord: Dictionary = {} # just the nodes
var cells_by_coord: Dictionary[Vector2, Cell] = {}

## init

func _init(puzz_def: PuzzleDef, g_def: GameDef) -> void:
	puzzle_def = puzz_def
	game_def = g_def

	for cell: GameDef.GridCell in game_def.grid_cells(puzzle_def):
		var coord := Vector2(cell.coord.x, cell.coord.y)
		cells_by_coord[coord] = Cell.new(coord, cell.objs, [])

	Log.pr(cells_by_coord)

	grid_xs = len(puzzle_def.shape[0])
	grid_ys = len(puzzle_def.shape)

## state updates

func add_player(coord: Vector2, node: DotHopPlayer) -> void:
	players.append(Player.new(coord, node))

func add_dot(coord: Vector2, node: Node2D) -> void:
	if not coord in nodes_by_coord:
		nodes_by_coord[coord] = []
	(nodes_by_coord[coord] as Array).append(node)

func set_nodes(cell: Cell, nodes: Array[DotHopDot]) -> void:
	cells_by_coord[cell.coord].nodes = nodes

## getters

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

func cell_at_coord(coord: Vector2) -> PuzzleState.Cell:
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
	if not "Undo" in cells_by_coord[coord].objs:
		cells_by_coord[coord].objs.append(GameDef.Obj.Undo)

func drop_undo(coord: Vector2) -> void:
	cells_by_coord[coord].objs.erase(GameDef.Obj.Undo)

func mark_player(coord: Vector2) -> void:
	cells_by_coord[coord].objs.append(GameDef.Obj.Player)

func drop_player(coord: Vector2) -> void:
	cells_by_coord[coord].objs.erase(GameDef.Obj.Player)

##################################################################
# public state updates
