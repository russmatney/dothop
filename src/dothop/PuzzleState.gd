@tool
extends Object
class_name PuzzleState

class Player:
	var coord: Vector2
	var stuck := false
	var move_history: Array = []
	var node: DotHopPlayer

	func _init(crd: Vector2, nd: DotHopPlayer) -> void:
		coord = crd
		node = nd

class Cell:
	var objs: Array
	var coord: Vector2
	var nodes: Array[Node2D]

	func _init(_objs: Array, _coord: Vector2, _nodes: Array) -> void:
		objs = _objs
		coord = _coord
		nodes.assign(_nodes)

class Move:
	enum MoveType {
		undo=0,
		stuck=1,
		blocked_by_player=2,
		move_to=3,
		}

	var fn: Callable
	var player: PuzzleState.Player
	var type: MoveType
	var cell: PuzzleState.Cell

	func _init(t: MoveType, p: PuzzleState.Player, fun: Variant = null, c: PuzzleState.Cell = null) -> void:
		type = t
		player = p
		if fun:
			fn = fun
		cell = c

	static func undo(p: PuzzleState.Player, fun: Callable) -> Move:
		return Move.new(MoveType.undo, p, fun)
	static func stuck(p: PuzzleState.Player) -> Move:
		return Move.new(MoveType.stuck, p)
	static func blocked_by_player(p: PuzzleState.Player) -> Move:
		return Move.new(MoveType.blocked_by_player, p)
	static func move_to(p: PuzzleState.Player, fun: Callable, c: PuzzleState.Cell) -> Move:
		return Move.new(MoveType.move_to, p, fun, c)

enum MoveResult {
	zero=0,
	move_not_allowed=1,
	stuck=2, # no legal destination in direction
	undo=3,
	moved=4,
	}


var win := false
var players: Array[Player] = []
var grid: Array
var grid_xs: int
var grid_ys: int
# var cell_nodes: Dictionary[Vector2, Array[Node2D]] = {}
var cell_nodes: Dictionary = {}

func _init(puzzle_def: PuzzleDef, game_def: GameDef) -> void:
	grid = []

	for y: int in len(puzzle_def.shape):
		var row: Array = puzzle_def.shape[y]
		var r: Array = []
		for x: int in len(row):
			var cell: Variant = puzzle_def.shape[y][x]
			# TODO convert these objs to an enum, probably at parse-time
			var objs: Variant = game_def.get_cell_objects(cell)
			r.append(objs)
		grid.append(r)

	grid_xs = len(grid[0])
	grid_ys = len(grid)

## getters

func coord_for_dot(dot: DotHopDot) -> Vector2:
	for coord: Vector2 in cell_nodes:
		if dot in cell_nodes[coord]:
			return coord
	return Vector2.ZERO

func all_coords() -> Array[Vector2]:
	var crds: Array[Vector2] = []
	for y: int in len(grid):
		for x: int in len(grid[y]):
			crds.append(Vector2(x, y))
	return crds

func objs_for_coord(coord: Vector2) -> Variant:
	return grid[int(coord.y)][int(coord.x)]

# Returns a list of cell object names
func all_cells() -> Array:
	var cs: Array = []
	for row: Array in grid:
		for cell: Variant in row:
			cs.append(cell)
	return cs

# Returns true if there are no "dot" objects in the state grid
func all_dotted() -> bool:
	return all_cells().all(func(c: Variant) -> bool:
		if c == null:
			return true
		for obj_name: String in c:
			if obj_name == "Dot":
				return false
		return true)

func dot_count(only_undotted: bool = false) -> int:
	return len(all_cells().filter(func(c: Variant) -> bool:
		if c == null:
			return false
		for obj_name: String in c:
			if only_undotted and obj_name in ["Dot"]:
				return true
			elif not only_undotted and obj_name in ["Dot", "Dotted"]:
				return true
		return false))


func all_players_at_goal() -> bool:
	return all_cells().filter(func(c: Variant) -> bool:
		return c != null and "Goal" in c
		).all(func(c: Array) -> bool: return "Player" in c)

## state updates

func add_player(coord: Vector2, node: DotHopPlayer) -> void:
	players.append(Player.new(coord, node))

func add_dot(coord: Vector2, node: Node2D) -> void:
	if not coord in cell_nodes:
		cell_nodes[coord] = []
	(cell_nodes[coord] as Array).append(node)

func mark_dotted(coord: Vector2) -> void:
	@warning_ignore("unsafe_method_access")
	grid[coord.y][coord.x].erase("Dot")
	@warning_ignore("unsafe_method_access")
	grid[coord.y][coord.x].append("Dotted")

func mark_undotted(coord: Vector2) -> void:
	@warning_ignore("unsafe_method_access")
	grid[coord.y][coord.x].erase("Dotted")
	@warning_ignore("unsafe_method_access")
	grid[coord.y][coord.x].append("Dot")

func mark_undo(coord: Vector2) -> void:
	if not "Undo" in grid[coord.y][coord.x]:
		@warning_ignore("unsafe_method_access")
		grid[coord.y][coord.x].append("Undo")

func drop_undo(coord: Vector2) -> void:
	@warning_ignore("unsafe_method_access")
	grid[coord.y][coord.x].erase("Undo")

func mark_player(coord: Vector2) -> void:
	@warning_ignore("unsafe_method_access")
	grid[coord.y][coord.x].append("Player")

func drop_player(coord: Vector2) -> void:
	@warning_ignore("unsafe_method_access")
	grid[coord.y][coord.x].erase("Player")
