@tool
extends Node2D
class_name DotHopPuzzle

# TODO move all vector2 to vector2i?
# TODO refactor 'state', 'player', 'cell', 'move' into well-typed internal classes

## static ##########################################################################

static var fallback_puzzle_scene: String = "res://src/puzzle/PuzzleScene.tscn"

# Builds and returns a "puzzle_scene" node, with a game_def and puzzle_def set
# Accepts several input options, but only 'game_def' or 'game_def_path' are required.
#
# A raw puzzle or puzzle_num can be specified to load/pick a puzzle for a particular game_def.
# `puzzle_scene` should be set according to the current theme.
#
# This func could live on the DotHopGame script, but a function like this is useful
# for testing just the game logic (without loading a full DotHopGame)
static func build_puzzle_node(opts: Dictionary) -> DotHopPuzzle:
	# parse the puzzle script game, set game_def
	var _game_def: GameDef = opts.get("game_def")
	if not _game_def and opts.get("game_def_path"):
		_game_def = Puzz.parse_game_def(str(opts.get("game_def_path")))

	if _game_def == null:
		Log.warn("No game_def passed, cannot build_puzzle_node()", opts)
		return

	# parse/pick the puzzle to load
	var puzzle: Variant = opts.get("puzzle")
	# default to loading the first puzzle
	var _puzzle_num: int = opts.get("puzzle_num", 0)
	var _puzzle_def: PuzzleDef

	if puzzle is Array:
		_puzzle_def = Puzz.parse_puzzle_def(puzzle as Array)
	elif _puzzle_num != null:
		_puzzle_def = _game_def.puzzles[_puzzle_num]
	else:
		pass

	if _puzzle_def == null or _puzzle_def.shape == null:
		Log.warn("Could not determine _puzzle_def, cannot build_puzzle_node()")
		return

	var _theme: PuzzleTheme = opts.get("puzzle_theme")
	var _theme_data: PuzzleThemeData = opts.get("puzzle_theme_data")
	var scene: PackedScene = opts.get("puzzle_scene", _theme_data.puzzle_scene if _theme_data else null)
	if scene == null and opts.get("puzzle_scene_path") != null:
		# TODO Drop support for this unless we use it (maybe in tests?)
		scene = load(str(opts.get("puzzle_scene_path")))
	if scene == null:
		scene = load(fallback_puzzle_scene)

	var node: DotHopPuzzle = scene.instantiate()

	node.game_def = _game_def
	node.theme = _theme
	node.theme_data = _theme_data
	node.puzzle_def = _puzzle_def
	node.puzzle_num = _puzzle_num
	return node

## vars ##############################################################

@export_file var game_def_path: String = "res://src/puzzles/dothop-two.txt" :
	set(gdp):
		game_def_path = gdp
		if gdp != "":
			game_def = Puzz.parse_game_def(gdp)
			puzzle_def = game_def.puzzles[0]

@export var clear: bool = false:
	set(v):
		if v == true:
			clear_nodes()

@export var trigger_intro: bool = false:
	set(v):
		if v == true and Engine.is_editor_hint():
			Anim.puzzle_animate_intro_from_point(self)

@export var trigger_outro: bool = false:
	set(v):
		if v == true and Engine.is_editor_hint():
			Anim.puzzle_animate_outro_to_point(self)

@export var debugging: bool = false

@export var theme: PuzzleTheme
@export var theme_data: PuzzleThemeData
var game_def : GameDef
var puzzle_def : PuzzleDef :
	set(ld):
		puzzle_def = ld
		if Engine.is_editor_hint():
			init_game_state()
@export var square_size: int = 32

@export var puzzle_num : int :
	set(pn):
		puzzle_num = pn
		if Engine.is_editor_hint():
			if game_def:
				puzzle_def = game_def.puzzles[pn]


# um what no let's get some types here
var state: PuzzState
class PuzzState:
	var win := false
	var players: Array[Player] = []
	var grid: Array
	var grid_xs: int
	var grid_ys: int
	# var cell_nodes: Dictionary[Vector2, Array[Node2D]] = {}
	var cell_nodes: Dictionary = {}

	func _init(gd: Array) -> void:
		grid = gd
		grid_xs = len(gd[0])
		grid_ys = len(gd)

class Player:
	var coord: Vector2
	var stuck := false
	var move_history: Array = []
	var node: Node2D

	func _init(crd: Vector2, nd: Node) -> void:
		coord = crd
		node = nd

signal win

# hud updates
signal player_moved
signal player_undo
signal move_rejected
signal move_blocked
signal rebuilt_nodes

var obj_type: Dictionary = {
	"Dot": DHData.dotType.Dot,
	"Dotted": DHData.dotType.Dotted,
	"Goal": DHData.dotType.Goal,
	}

## enter_tree ##############################################################

func _init() -> void:
	add_to_group(DHData.puzzle_group, true)

## ready ##############################################################

@export var randomize_layout: bool = true
var reverse_ys: bool = false
var reverse_xs: bool = false
var rotate_shape: bool = false

func _ready() -> void:
	if puzzle_def == null:
		Log.pr("no puzzle_def, trying backups!", name)
		if game_def_path != "":
			game_def = Puzz.parse_game_def(game_def_path)
			puzzle_def = game_def.puzzles[0]
		else:
			Log.err("no game_def_path!!")

	if randomize_layout:
		reverse_ys = U.rand_of([true, false])
		reverse_xs = U.rand_of([true, false])
		rotate_shape = U.rand_of([true, false, false, false])

	if puzzle_def:
		if reverse_ys:
			puzzle_def.shape.reverse()
		if reverse_xs:
			for row: Array in puzzle_def.shape:
				row.reverse()
		if rotate_shape:
			# don't rotate very wide puzzles
			if puzzle_def.width <= 6:
				puzzle_def.rotate()
		init_game_state()

	win.connect(on_win)
	player_moved.connect(on_player_moved)
	player_undo.connect(on_player_undo)
	move_rejected.connect(on_move_rejected)
	move_blocked.connect(on_move_blocked)
	rebuilt_nodes.connect(on_rebuilt_nodes)

func on_win() -> void:
	Sounds.play(Sounds.S.complete)

func on_player_moved() -> void:
	var total_dots: float = float(dot_count() + 1)
	var dotted: float = total_dots - float(dot_count(true)) - 1
	# ensure some minimum
	dotted = clamp(dotted, total_dots/4, total_dots)
	if state.win:
		dotted += 1
	Sounds.play(Sounds.S.dot_collected, {scale_range=total_dots, scale_note=dotted, interrupt=true})

func on_player_undo() -> void:
	Sounds.play(Sounds.S.minimize)

func on_move_rejected() -> void:
	Sounds.play(Sounds.S.showjumbotron)

func on_move_blocked() -> void:
	pass

func on_rebuilt_nodes() -> void:
	Sounds.play(Sounds.S.maximize)


## input ##############################################################

var just_logged_blocked_input: bool = false
func _unhandled_input(event: InputEvent) -> void:
	if state != null and state.win:
		if not just_logged_blocked_input:
			Log.pr("Blocking input events b/c we're in a win state")
			just_logged_blocked_input = true
		return
	just_logged_blocked_input = false

	if Trolls.is_move(event):
		if state == null:
			Log.warn("No state, ignoring move input")
			return
		check_move_input(event)
	elif Trolls.is_undo(event) and not block_move:
		if state == null:
			Log.warn("No state, ignoring undo input")
			return
		for p: Player in state.players:
			undo_last_move(p)
		restart_block_move_timer(0.1)

	elif Trolls.is_restart_held(event):
		hold_to_reset_puzzle()
	elif Trolls.is_restart_released(event):
		cancel_reset_puzzle()
	elif Trolls.is_debug_toggle(event):
		Log.pr(state.grid)

var reset_tween: Tween
func hold_to_reset_puzzle() -> void:
	if reset_tween != null and reset_tween.is_running():
		# already holding
		return
	reset_tween = create_tween()
	reset_tween.tween_callback(init_game_state).set_delay(DHData.reset_hold_t)

func cancel_reset_puzzle() -> void:
	if reset_tween == null:
		return
	reset_tween.kill()

func reset_pressed() -> void:
	init_game_state()

func undo_pressed() -> void:
	if state == null:
		Log.warn("No state, ignoring undo input")
		return
	for p: Player in state.players:
		undo_last_move(p)


## check_move_input ##############################################################

var block_move: bool
var last_move: Vector2

func check_move_input(event: InputEvent = null, move_vec: Vector2 = Vector2.ZERO) -> void:
	if move_vec == Vector2.ZERO:
		move_vec = Trolls.grid_move_vector(event)

	if move_vec != last_move:
		# allow moving in a new direction
		block_move = false

	if move_vec != Vector2.ZERO and not block_move:
		last_move = move_vec
		move(move_vec)
		restart_block_move_timer()
	elif block_move:
		move_blocked.emit()

var block_move_timer: Tween
func restart_block_move_timer(t: float = 0.2) -> void:
	block_move = true
	if block_move_timer != null:
		block_move_timer.kill()
	block_move_timer = create_tween()
	block_move_timer.tween_callback(func() -> void:
		block_move = false
		check_move_input()).set_delay(t)

func on_dot_pressed(_type: DHData.dotType, node: DotHopDot) -> void:
	# calc move_vec for tapped dot with first player
	var first_player_coord: Variant
	for p: Player in state.players:
		if p.coord != null:
			first_player_coord = p.coord
			break
	if first_player_coord == null:
		Log.warn("Cannot move to dot, no player coord found")
		return

	var move_vec: Vector2 = node.current_coord - first_player_coord
	if move_vec.x == 0 or move_vec.y == 0:
		check_move_input(null, move_vec.normalized())
	else:
		Log.info("Cannot move to dot", node, node.current_coord)


## state/grid ##############################################################

# sets up the state grid and some initial data based on the assigned puzzle_def
func init_game_state() -> void:
	if len(puzzle_def.shape) == 0:
		Log.warn("init_game_state() called without puzzle_def.shape", puzzle_def)
		return

	var grid: Array = []
	for y: int in len(puzzle_def.shape):
		var row: Array = puzzle_def.shape[y]
		var r: Array = []
		for x: int in len(row):
			var cell: Variant = puzzle_def.shape[y][x]
			var objs: Variant = game_def.get_cell_objects(cell)
			r.append(objs)
		grid.append(r)

	# state = {players=players, grid=grid, grid_xs=len(grid[0]), grid_ys=len(grid), win=false, cell_nodes={}}
	state = PuzzState.new(grid)

	rebuild_nodes()


## setup level ##############################################################

func init_player(coord: Vector2, node: Node) -> Player:
	return Player.new(coord, node)
	# return {coord=coord, stuck=false, move_history=[], node=node}

func clear_nodes() -> void:
	for ch: Variant in get_children():
		if not ch is CanvasItem:
			continue
		var ci: CanvasItem = ch as CanvasItem
		if ci.is_in_group("generated"):
			# hide flicker while we wait for queue_free
			ci.set_visible(false)
			ci.queue_free()

var dhcam_scene: PackedScene = preload("res://src/DotHopCam.tscn")
var dhcam: DotHopCam
func ensure_camera() -> void:
	if len(state.grid) == 0:
		return

	dhcam = get_node_or_null("DotHopCam")
	if dhcam == null:
		dhcam = get_parent().get_node_or_null("DotHopCam")
	if dhcam == null:
		dhcam = dhcam_scene.instantiate()
		add_child(dhcam)

func coord_pos(node: Node2D) -> Vector2:
	if node.has_method("current_position"):
		return node.call("current_position")
	else:
		return node.position

func puzzle_rect(opts: Dictionary = {}) -> Rect2:
	var nodes: Array = puzzle_cam_nodes(opts)
	var rect: Rect2 = Rect2(coord_pos(nodes[0] as Node2D), Vector2.ZERO)
	for node: Variant in nodes:
		if "square_size" in node:
			# scale might also be a factor
			var bot_right: Vector2 = coord_pos(node as Node2D) + node.square_size * Vector2.ONE * 1.0
			# why the half here?
			var top_left_half: Vector2 = coord_pos(node as Node2D) - node.square_size * Vector2.ONE * 0.5
			rect = rect.expand(bot_right).expand(top_left_half)
		else:
			rect = rect.expand(coord_pos(node as Node2D))
	return rect

func puzzle_cam_nodes(opts: Dictionary = {}) -> Array:
	var cam_nodes: Array = []
	var nodes: Array
	if opts.get("dots_only"):
		nodes = all_cell_nodes({filter=func(node: DotHopDot) -> bool:
			return "type" in node and node.type in [DHData.dotType.Dot, DHData.dotType.Goal]})
	else:
		nodes = all_cell_nodes()
	cam_nodes.append_array(nodes)
	for p: Player in state.players:
		cam_nodes.append(p.node)
	return cam_nodes

# Adds nodes for the object_names in each cell of the grid.
# Tracks nodes (except for players) in a state.cell_nodes dict.
# Tracks players in state.players list.
func rebuild_nodes() -> void:
	clear_nodes()

	if not Engine.is_editor_hint() and is_inside_tree():
		ensure_camera()

	var players: Array = []
	for y: int in len(state.grid):
		for x: int in len(state.grid[y]):
			var objs: Variant = state.grid[y][x]
			if objs == null:
				continue
			for obj_name: String in objs:
				var coord: Vector2 = Vector2(x, y)
				var node: Node2D = create_node_at_coord(obj_name, coord)
				if obj_name == "Player":
					state.players.append(init_player(coord, node))
					players.append(node)
				else:
					add_child(node)
					if not coord in state.cell_nodes:
						state.cell_nodes[coord] = []
					(state.cell_nodes[coord] as Array).append(node)

	for p: Node in players:
		add_child(p)

	if dhcam != null:
		dhcam.center_on_rect(puzzle_rect({dots_only=true}))

	# trigger HUD update
	rebuilt_nodes.emit()

func create_node_at_coord(obj_name:String, coord:Vector2) -> Node:
	var node: Node2D = node_for_object_name(obj_name)
	# nodes should maybe set their own position
	# (i.e. not be automatically moved, but stay on the puzzle's origin)
	@warning_ignore("unsafe_property_access")
	node.square_size = square_size
	if node.has_method("set_initial_coord"):
		@warning_ignore("unsafe_method_access")
		node.set_initial_coord(coord)
	else:
		node.position = coord * square_size
	node.add_to_group("generated", true)
	if debugging or not Engine.is_editor_hint():
		node.ready.connect(func() -> void: node.set_owner(self))
	return node

func node_for_object_name(obj_name: String) -> Node2D:
	var scene: PackedScene = get_scene_for(obj_name)
	if not scene:
		Log.err("No scene found for object name", obj_name)
		return
	var node: Node2D = scene.instantiate()
	@warning_ignore("unsafe_property_access")
	node.display_name = obj_name
	var t: Variant = obj_type.get(obj_name)
	if t != null and "type" in node:
		@warning_ignore("unsafe_property_access")
		node.type = t
		if node.has_signal("dot_pressed"):
			@warning_ignore("unsafe_method_access")
			@warning_ignore("unsafe_property_access")
			node.dot_pressed.connect(on_dot_pressed.bind(t, node))
	elif obj_name not in ["Player"]:
		Log.warn("no type for object?", obj_name)
	return node

## custom nodes ##############################################################

var already_warned := false

func get_scene_for(obj_name: String) -> PackedScene:
	if theme_data == null and not already_warned:
		already_warned = true
		Log.warn("Missing expected theme_data")
	match obj_name:
		"Player": return PuzzleThemeData.get_player_scene(theme_data)
		"Dot": return PuzzleThemeData.get_dot_scene(theme_data)
		"Dotted": return PuzzleThemeData.get_dotted_scene(theme_data)
		"Goal": return PuzzleThemeData.get_goal_scene(theme_data)
		_: return

## grid helpers ##############################################################

# returns true if the passed coord is in the level's grid
func coord_in_grid(coord: Vector2) -> bool:
	return coord.x >= 0 and coord.y >= 0 and \
		coord.x < state.grid_xs and coord.y < state.grid_ys

class Cell:
	var objs: Array
	var coord: Vector2
	var nodes: Array[Node2D]

	func _init(_objs: Array, _coord: Vector2, _nodes: Array) -> void:
		objs = _objs
		coord = _coord
		nodes.assign(_nodes)

func cell_at_coord(coord: Vector2) -> Cell:
	var nodes: Array = state.cell_nodes.get(coord, [])
	var objs: Variant = state.grid[coord.y][coord.x]
	return Cell.new(objs as Array if objs else [], coord, nodes)
	# return {objs=state.grid[coord.y][coord.x], coord=coord, nodes=nodes}

# returns a list of cells from the passed position in the passed direction
# the cells are dicts with a coord, a list of objs (string names), and a list of nodes
func cells_in_direction(coord:Vector2, dir:Vector2) -> Array:
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

# Returns a list of cell object names
func all_cells() -> Array:
	if state == null:
		return []
	var cs: Array = []
	for row: Array in state.grid:
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

func all_cell_nodes(opts: Dictionary = {}) -> Array[Node2D]:
	var ns: Array = state.cell_nodes.values().reduce(func(agg: Array, nodes: Array) -> Array:
		if "filter" in opts:
			var f: Callable = opts.get("filter")
			nodes = nodes.filter(f)
		agg.append_array(nodes)
		return agg, []) # if we don't provide an initial val, the first node gets through FOR FREE
	var t_nodes: Array[Node2D] = []
	t_nodes.assign(ns)
	return t_nodes

## move/state-updates ##############################################################

func previous_undo_coord(player: Player, skip_coord: Vector2, start_at: int = 0) -> Variant:
	# pulls the first coord from player history that does not match `skip_coord`,
	# starting after `start_at`
	for m: Vector2 in player.move_history.slice(start_at):
		if m != skip_coord:
			return m
	return

# Move the player to the passed cell's coordinate.
# also updates the game state
# cell should have a `coord`
# NOTE updating move_history is done after all players move
func move_player_to_cell(player: Player, cell: Cell) -> Signal:
	# move player node
	var move_finished_sig: Signal
	if player.node.has_method("move_to_coord"):
		@warning_ignore("unsafe_method_access")
		var res: Variant = player.node.move_to_coord(cell.coord)
		if res != null:
			move_finished_sig = res
	else:
		player.node.position = cell.coord * square_size

	# update game state
	@warning_ignore("unsafe_method_access")
	state.grid[cell.coord.y][cell.coord.x].append("Player")
	@warning_ignore("unsafe_method_access")
	state.grid[player.coord.y][player.coord.x].erase("Player")

	# remove previous undo marker
	# NOTE start_at 1 b/c history has already been updated
	var prev_undo_coord: Variant
	if len(player.move_history) > 1:
		prev_undo_coord = previous_undo_coord(player, player.coord, 1)
	if prev_undo_coord != null:
		@warning_ignore("unsafe_method_access")
		state.grid[prev_undo_coord.y][prev_undo_coord.x].erase("Undo")

	# add new undo marker at current coord
	@warning_ignore("unsafe_method_access")
	state.grid[player.coord.y][player.coord.x].append("Undo")

	# update to new coord
	player.coord = cell.coord

	return move_finished_sig

# converts the dot at the cell's coord to a dotted one
# depends on cell for `coord` and `nodes`.
func mark_cell_dotted(cell: Cell) -> void:
	# support multiple nodes per cell?
	var node: DotHopDot = U.first(cell.nodes)
	if node == null:
		Log.warn("can't mark dotted, no node found!", cell)
		return

	if node.has_method("mark_dotted"):
		node.mark_dotted()
	else:
		Log.warn("some strange node loaded?")
		node.display_name = "Dotted"

	# update game state
	@warning_ignore("unsafe_method_access")
	state.grid[cell.coord.y][cell.coord.x].erase("Dot")
	@warning_ignore("unsafe_method_access")
	state.grid[cell.coord.y][cell.coord.x].append("Dotted")

# converts dotted back to dot (undo)
# depends on cell for `coord` and `nodes`.
func mark_cell_undotted(cell: Cell) -> void:
	# support multiple nodes per cell?
	var node: DotHopDot = U.first(cell.nodes)
	if node == null:
		# undoing from goal doesn't require any undotting
		return

	if node.has_method("mark_undotted"):
		node.mark_undotted()
	else:
		Log.warn("some strange node loaded?")
		node.display_name = "Dot"

	# update game state
	@warning_ignore("unsafe_method_access")
	state.grid[cell.coord.y][cell.coord.x].erase("Dotted")
	@warning_ignore("unsafe_method_access")
	state.grid[cell.coord.y][cell.coord.x].append("Dot")

## move to dot ##############################################################

func move_to_dot(player: Player, cell: Cell) -> void:
	# consider handling these in the same step (depending on the animation)
	move_player_to_cell(player, cell)
	mark_cell_dotted(cell)

## move to goal ##############################################################

func move_to_goal(player: Player, cell: Cell) -> void:
	var move_finished: Signal = move_player_to_cell(player, cell)
	if all_dotted() and all_players_at_goal():
		state.win = true
		if move_finished:
			await move_finished
		win.emit()
	else:
		player.stuck = true

## undo last move ##############################################################

func undo_last_move(player: Player) -> void:
	# supports the solver - undo moves state.win back to false
	state.win = false

	if len(player.move_history) == 0:
		Log.warn("Can't undo, no moves yet!")
		return
	# remove last move from move_history
	var last_pos: Vector2 = player.move_history.pop_front()
	var dest_cell: Cell = cell_at_coord(last_pos)

	# need to walk back the grid's Undo markers
	var prev_undo_coord: Variant = previous_undo_coord(player, dest_cell.coord, 0)
	if prev_undo_coord != null:
		if not "Undo" in state.grid[prev_undo_coord.y][prev_undo_coord.x]:
			@warning_ignore("unsafe_method_access")
			state.grid[prev_undo_coord.y][prev_undo_coord.x].append("Undo")
	@warning_ignore("unsafe_method_access")
	state.grid[dest_cell.coord.y][dest_cell.coord.x].erase("Undo")

	if last_pos == player.coord:
		if player.node.has_method("undo_to_same_coord"):
			@warning_ignore("unsafe_method_access")
			player.node.undo_to_same_coord()
		return

	# move player node
	if player.node.has_method("undo_to_coord"):
		@warning_ignore("unsafe_method_access")
		player.node.undo_to_coord(dest_cell.coord)
	else:
		player.node.position = dest_cell.coord * square_size

	# update game state
	@warning_ignore("unsafe_method_access")
	state.grid[dest_cell.coord.y][dest_cell.coord.x].append("Player")
	@warning_ignore("unsafe_method_access")
	state.grid[player.coord.y][player.coord.x].erase("Player")

	if "Dotted" in state.grid[player.coord.y][player.coord.x]:
		# undo at the current player position
		mark_cell_undotted(cell_at_coord(player.coord))
	if "Goal" in state.grid[player.coord.y][player.coord.x]:
		# unstuck when undoing from the goal
		player.stuck = false

	# update state player position
	player.coord = dest_cell.coord

	player_undo.emit()

## move ##############################################################

# attempt to move all players in move_dir
# any undos (movement backwards) undos the last movement
# if any player is stuck, only undo is allowed
# otherwise, the player moves to the dot or goal in the direction pressed
# return true if the move was made successfully
func move(move_dir: Vector2) -> bool:
	if move_dir == Vector2.ZERO:
		# don't do anything!
		return false

	var moves_to_make: Array = []
	for p: Player in state.players:
		var cells: Array = cells_in_direction(p.coord, move_dir)
		if len(cells) == 0:
			if p.stuck:
				moves_to_make.append(["stuck", null, p])
				if p.node.has_method("move_attempt_stuck"):
					@warning_ignore("unsafe_method_access")
					p.node.move_attempt_stuck(move_dir)
			else:
				if p.node.has_method("move_attempt_away_from_edge"):
					@warning_ignore("unsafe_method_access")
					p.node.move_attempt_away_from_edge(move_dir)
			continue

		cells = cells.filter(func(c: Cell) -> bool: return len(c.objs) > 0)
		if len(cells) == 0:
			if p.stuck:
				moves_to_make.append(["stuck", null, p])
				if p.node.has_method("move_attempt_stuck"):
					@warning_ignore("unsafe_method_access")
					p.node.move_attempt_stuck(move_dir)
			else:
				if p.node.has_method("move_attempt_only_nulls"):
					@warning_ignore("unsafe_method_access")
					p.node.move_attempt_only_nulls(move_dir)
			continue

		# instead of markers, read undo based on only the player move history?
		var undo_cell_in_dir: Variant = U.first(cells.filter(func(c: Cell) -> bool: return "Undo" in c.objs and c.coord in p.move_history))

		if undo_cell_in_dir != null:
			moves_to_make.append(["undo", undo_last_move, p, undo_cell_in_dir])
		else:
			for cell: Cell in cells:
				if p.stuck:
					# Log.warn("stuck, didn't see an undo in dir", move_dir, p.move_history)
					moves_to_make.append(["stuck", null, p])
					if p.node.has_method("move_attempt_stuck"):
						@warning_ignore("unsafe_method_access")
						p.node.move_attempt_stuck(move_dir)
					break
				if "Player" in cell.objs:
					moves_to_make.append(["blocked_by_player", null, p])
					# moving toward player animation?
					break
				if "Dotted" in cell.objs:
					# play move 'blocked' animation
					if p.node.has_method("move_attempt_stuck"):
						@warning_ignore("unsafe_method_access")
						p.node.move_attempt_stuck(move_dir)
					continue
				if "Dot" in cell.objs:
					moves_to_make.append(["dot", move_to_dot, p, cell])
					break
				if "Goal" in cell.objs:
					moves_to_make.append(["goal", move_to_goal, p, cell])
					break
				Log.warn("unexpected/unhandled cell in direction", cell)

	var any_move: bool = moves_to_make.any(func(m: Array) -> bool: return m[0] in ["dot", "goal"])
	if any_move:
		for p: Player in state.players:
			p.move_history.push_front(p.coord)

		for m: Array in moves_to_make:
			if m[0] in ["dot", "goal"]:
				@warning_ignore("unsafe_method_access")
				m[1].call(m[2], m[3])

		# trigger HUD update
		player_moved.emit()
		return true # we moved!

	var any_undo: bool = moves_to_make.any(func(m: Array) -> bool: return m[0] == "undo")
	if any_undo:
		for m: Array in moves_to_make:
			# this is wonky, i should refactor to use a dict/struct for these movesh
			undo_last_move(m[2] as Player)
		return false

	# trigger HUD update
	move_rejected.emit()

	return false
