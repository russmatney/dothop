@tool
extends Node2D
class_name DotHopPuzzle

# TODO move all vector2 to vector2i?

const ALLOWED_MOVES := [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

## static ##########################################################################

static var fallback_puzzle_scene: String = "res://src/dothop/DotHopPuzzle.tscn"
static var fallback_puzzle_set_data: String = "res://src/puzzles/Tutorial.tres"

# Builds and returns a "puzzle_scene" node.
#
# A raw puzzle or puzzle_num can be specified to load/pick a puzzle for a particular game_def.
# `puzzle_scene` should be set according to the current theme.
static func build_puzzle_node(opts: Dictionary) -> DotHopPuzzle:
	# parse/ensure game def ######################################333
	# parse the puzzle script game, set game_def
	var _game_def: GameDef = opts.get("game_def")
	if not _game_def:
		Log.info("no game def passed, using fallback")
		var psd : PuzzleSetData = load(fallback_puzzle_set_data)
		_game_def = psd.parse_game_def()

	# parse/ensure puzzle def ####################################
	# parse/pick the puzzle to load
	var puzzle: Variant = opts.get("puzzle") # used to pass puzzles in tests
	# default to loading the first puzzle
	var _puzzle_num: int = opts.get("puzzle_num", 0)
	var _puzzle_def: PuzzleDef

	if puzzle is Array:
		_puzzle_def = GameDef.parse_puzzle_def(puzzle as Array)
	elif _puzzle_num != null:
		_puzzle_def = _game_def.puzzles[_puzzle_num]

	if _puzzle_def == null or _puzzle_def.shape == null:
		Log.warn("Could not determine _puzzle_def, cannot build_puzzle_node()")
		return

	###############################################################
	# create puzzle scene node and set values
	var _theme: PuzzleTheme = opts.get("puzzle_theme")
	var scene: PackedScene = opts.get("puzzle_scene", _theme.get_puzzle_scene())
	if scene == null:
		scene = load(DotHopPuzzle.fallback_puzzle_scene)

	var node: DotHopPuzzle = scene.instantiate()
	node.game_def = _game_def
	node.theme = _theme
	node.theme_data = _theme.get_theme_data()
	node.puzzle_def = _puzzle_def
	node.puzzle_num = _puzzle_num
	return node

## vars ##############################################################

@export var clear: bool = false:
	set(v):
		if v == true:
			clear_nodes()

@export var min_t : float = 0.1
@export var max_t : float = 1.0

@export var trigger_intro: bool = false:
	set(v):
		if v == true and Engine.is_editor_hint():
			Anim.puzzle_animate_intro_from_point(self, min_t, max_t)

@export var trigger_outro: bool = false:
	set(v):
		if v == true and Engine.is_editor_hint():
			Anim.puzzle_animate_outro_to_point(self)

@export var debugging: bool = false

@export var theme: PuzzleTheme
var theme_data: PuzzleThemeData
var game_def : GameDef
var puzzle_def : PuzzleDef :
	set(ld):
		puzzle_def = ld
		if Engine.is_editor_hint():
			build_game_state()
@export var square_size: int = 32

@export var puzzle_num : int :
	set(pn):
		puzzle_num = pn
		if Engine.is_editor_hint():
			if game_def:
				puzzle_def = game_def.puzzles[pn]

var dhcam: DotHopCam

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

	func coord_for_dot(dot: DotHopDot) -> Vector2:
		for coord: Vector2 in cell_nodes:
			if dot in cell_nodes[coord]:
				return coord
		return Vector2.ZERO

	func objs_for_coord(coord: Vector2) -> Variant:
		return grid[int(coord.y)][int(coord.x)]

	func all_coords() -> Array[Vector2]:
		var crds: Array[Vector2] = []
		for y: int in len(grid):
			for x: int in len(grid[y]):
				crds.append(Vector2(x, y))
		return crds

	func add_player(coord: Vector2, node: Node2D) -> void:
		players.append(Player.new(coord, node))

	func add_dot(coord: Vector2, node: Node2D) -> void:
		if not coord in cell_nodes:
			cell_nodes[coord] = []
		(cell_nodes[coord] as Array).append(node)

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
signal move_input_blocked
signal rebuilt_nodes

## enter_tree ##############################################################

func _init() -> void:
	add_to_group(DHData.puzzle_group, true)

## ready ##############################################################

@export var randomize_layout: bool = true
var reverse_ys: bool = false
var reverse_xs: bool = false
var rotate_shape: bool = false

# PuzzleScene.ready()
# in the local-testing case, we want to look up and assign a theme-data
func _ready() -> void:
	if puzzle_def == null:
		Log.info("no puzzle_def, loading fallback", name)
		var psd : PuzzleSetData = load(fallback_puzzle_set_data)
		game_def = psd.parse_game_def()
		puzzle_def = game_def.puzzles[0]

	if theme_data == null and theme != null:
		theme_data = theme.get_theme_data()
		if theme_data == null:
			Log.warn("Puzzle Scene running with no theme data!")

	if randomize_layout:
		reverse_ys = U.rand_of([true, false])
		reverse_xs = U.rand_of([true, false])
		rotate_shape = U.rand_of([true, false, false, false])

	if not Engine.is_editor_hint() and is_inside_tree():
		dhcam = DotHopCam.ensure_camera(self)

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
		build_game_state()

	win.connect(on_win)
	player_moved.connect(on_player_moved)
	player_undo.connect(on_player_undo)
	move_rejected.connect(on_move_rejected)
	move_input_blocked.connect(on_move_input_blocked)
	rebuilt_nodes.connect(on_rebuilt_nodes)

	input_block_timer_done.connect(reattempt_blocked_move)

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

func on_move_input_blocked() -> void:
	pass

func on_rebuilt_nodes() -> void:
	Sounds.play(Sounds.S.maximize)

## process ##############################################################

# func _process(_delta: float) -> void:
# 	process_move_queue()

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
		var move_dir: Vector2 = Trolls.grid_move_vector(event)
		attempt_move(move_dir)
	elif Trolls.is_undo(event) and not block_move_input:
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
	reset_tween.tween_callback(build_game_state).set_delay(DHData.reset_hold_t)

func cancel_reset_puzzle() -> void:
	if reset_tween == null:
		return
	reset_tween.kill()

func reset_pressed() -> void:
	build_game_state()

func undo_pressed() -> void:
	if state == null:
		Log.warn("No state, ignoring undo input")
		return
	for p: Player in state.players:
		undo_last_move(p)


## attempt_move ##############################################################

var block_move_input: bool
var last_move: Vector2 = Vector2.ZERO
signal input_block_timer_done

func attempt_move(move_vec: Vector2 = Vector2.ZERO) -> Variant:
	if move_vec != last_move:
		# allow moving in a new direction
		block_move_input = false

	if move_vec != Vector2.ZERO and not block_move_input:
		last_move = move_vec
		var move_result := move(move_vec)
		restart_block_move_timer()
		return move_result
	elif block_move_input:
		last_move = Vector2.ZERO
		move_input_blocked.emit()
	return false

var block_move_timer: Tween
func restart_block_move_timer(t: float = 0.2) -> void:
	block_move_input = true
	if block_move_timer != null:
		block_move_timer.kill()
	block_move_timer = create_tween()
	block_move_timer.tween_callback(func() -> void:
		block_move_input = false
		input_block_timer_done.emit()
		).set_delay(t)

func on_dot_pressed(node: DotHopDot) -> void:
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
		attempt_move(move_vec.normalized())
	else:
		Log.info("Cannot move to dot", node, node.current_coord)
		# TODO shake the tapped dot

## move_queue ##############################################################

var move_queue: Array[DotHopDot] = []
var last_dot_dragged: DotHopDot = null

func on_dot_mouse_dragged(dot: DotHopDot) -> void:
	# TODO handle blocked input (clicking through jumbotron in win state)

	# prevent dragging in the same dot from firing multiple times
	if dot == last_dot_dragged:
		return
	last_dot_dragged = dot

	if not dot in move_queue:
		move_queue.append(dot)
	else:
		# don't call process if this dot is already queued
		return

	process_move_queue.call_deferred()

var processing_move_queue := false

func process_move_queue(skip_check:=false) -> void:
	if not skip_check and processing_move_queue:
		return
	if move_queue.is_empty() or len(state.players) == 0:
		processing_move_queue = false
		return
	processing_move_queue = true

	var dot: DotHopDot = move_queue[0]
	var player: Player = state.players[0]
	var dir := (state.coord_for_dot(dot) - player.coord).normalized()

	if dir == Vector2.ZERO:
		move_queue.pop_front()
		# loop! until early exit
		process_move_queue(true)
		return

	var res: Variant = attempt_move(dir)
	if res is bool and res == false:
		Log.info("No move made, is input blocked?")
	elif res in [MoveResult.stuck, MoveResult.zero, MoveResult.move_not_allowed, MoveResult.undo]:
		# TODO shake the unreachable dot!
		move_queue.pop_front()
		last_dot_dragged = null
	elif res in [MoveResult.moved]:
		move_queue.pop_front()
		last_dot_dragged = null
	else:
		Log.warn("Unhandled move result", res)
		move_queue.pop_front()

	# loop! until early exit
	process_move_queue(true)

func reattempt_blocked_move() -> void:
	if processing_move_queue:
		process_move_queue(true)


## state/grid ##############################################################

# sets up the state grid and some initial data based on the assigned puzzle_def
func build_game_state() -> void:
	state = PuzzState.new(puzzle_def, game_def)
	rebuild_nodes()

# Adds nodes for the object_names in each cell of the grid.
# Tracks nodes (except for players) in a state.cell_nodes dict.
# Tracks players in state.players list.
func rebuild_nodes() -> void:
	clear_nodes()

	var players: Array = []
	for coord in state.all_coords():
		var objs: Variant = state.objs_for_coord(coord)
		if objs == null:
			continue
		for obj_name: String in objs:
			var node: Node2D = setup_node_at_coord(obj_name, coord)
			if node is DotHopPlayer:
				state.add_player(coord, node)
				players.append(node)
			elif node is DotHopDot:
				var dot: DotHopDot = node
				dot.dot_pressed.connect(on_dot_pressed.bind(dot))
				dot.mouse_dragged.connect(on_dot_mouse_dragged.bind(dot))
				add_child(dot)
				state.add_dot(coord, dot)

	# wait to add players last (so they end up on top)
	for p: Node in players:
		add_child(p)

	if dhcam != null:
		dhcam.center_on_rect(puzzle_rect({dots_only=true}))

	# trigger HUD update
	rebuilt_nodes.emit()

func setup_node_at_coord(obj_name:String, coord:Vector2) -> Node:
	var node: Node2D = node_for_object_name(obj_name)
	node.add_to_group("generated", true)
	if node is DotHopDot:
		var dot: DotHopDot = node
		dot.square_size = square_size
		dot.set_initial_coord(coord)
	elif node is DotHopPlayer:
		var p: DotHopPlayer = node
		p.square_size = square_size
		p.set_initial_coord(coord)
	if debugging or not Engine.is_editor_hint():
		node.ready.connect(node.set_owner.bind(self))
	return node

func node_for_object_name(obj_name: String) -> Node2D:
	var scene: PackedScene = get_scene_for(obj_name)
	if not scene:
		Log.err("No scene found for object name", obj_name)
		return
	var node: Node2D = scene.instantiate()
	if node is DotHopDot:
		var dot: DotHopDot = node
		dot.display_name = obj_name
		dot.type = obj_type.get(obj_name)
	if node is DotHopPlayer:
		var p: DotHopPlayer = node
		p.display_name = obj_name
	return node

var obj_type: Dictionary = {
	"Dot": DHData.dotType.Dot,
	"Dotted": DHData.dotType.Dotted,
	"Goal": DHData.dotType.Goal,
	}

func get_scene_for(obj_name: String) -> PackedScene:
	match obj_name:
		"Player": return PuzzleThemeData.get_player_scene(theme_data)
		"Dot": return PuzzleThemeData.get_dot_scene(theme_data)
		"Dotted": return PuzzleThemeData.get_dotted_scene(theme_data)
		"Goal": return PuzzleThemeData.get_goal_scene(theme_data)
		_: return

## setup level ##############################################################

func clear_nodes() -> void:
	for ch: Variant in get_children():
		if not ch is CanvasItem:
			continue
		var ci: CanvasItem = ch as CanvasItem
		if ci.is_in_group("generated"):
			# hide flicker while we wait for queue_free
			ci.set_visible(false)
			ci.queue_free()

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

class Move:
	enum MoveType {
		undo=0,
		stuck=1,
		blocked_by_player=2,
		move_to=3,
		}

	var fn: Callable
	var player: Player
	var type: MoveType
	var cell: Cell

	func _init(t: MoveType, p: Player, fun: Variant = null, c: Cell = null) -> void:
		type = t
		player = p
		if fun:
			fn = fun
		cell = c

	static func undo(p: Player, fun: Callable) -> Move:
		return Move.new(MoveType.undo, p, fun)
	static func stuck(p: Player) -> Move:
		return Move.new(MoveType.stuck, p)
	static func blocked_by_player(p: Player) -> Move:
		return Move.new(MoveType.blocked_by_player, p)
	static func move_to(p: Player, fun: Callable, c: Cell) -> Move:
		return Move.new(MoveType.move_to, p, fun, c)

enum MoveResult {
	zero=0,
	move_not_allowed=1,
	stuck=2, # no legal destination in direction
	undo=3,
	moved=4,
	}

# attempt to move all players in move_dir
# any undos (movement backwards) unwinds the last move
# if any player is stuck, only undo is allowed
# otherwise, the player moves to the dot or goal in the direction pressed
# return true if the move was made successfully
func move(move_dir: Vector2) -> MoveResult:
	if move_dir == Vector2.ZERO:
		# don't do anything!
		return MoveResult.zero
	if not move_dir in ALLOWED_MOVES:
		return MoveResult.move_not_allowed

	var moves_to_make: Array = []
	for p: Player in state.players:
		var cells: Array = cells_in_direction(p.coord, move_dir)
		if len(cells) == 0:
			if p.stuck:
				moves_to_make.append(Move.stuck(p))
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
				moves_to_make.append(Move.stuck(p))
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
			moves_to_make.append(Move.undo(p, undo_last_move))
		else:
			for cell: Cell in cells:
				if p.stuck:
					# Log.warn("stuck, didn't see an undo in dir", move_dir, p.move_history)
					moves_to_make.append(Move.stuck(p))
					if p.node.has_method("move_attempt_stuck"):
						@warning_ignore("unsafe_method_access")
						p.node.move_attempt_stuck(move_dir)
					break
				if "Player" in cell.objs:
					moves_to_make.append(Move.blocked_by_player(p))
					# moving toward player animation?
					break
				if "Dotted" in cell.objs:
					# play move 'blocked' animation
					if p.node.has_method("move_attempt_stuck"):
						@warning_ignore("unsafe_method_access")
						p.node.move_attempt_stuck(move_dir)
					continue
				if "Dot" in cell.objs:
					moves_to_make.append(Move.move_to(p, move_to_dot, cell))
					break
				if "Goal" in cell.objs:
					moves_to_make.append(Move.move_to(p, move_to_goal, cell))
					break
				Log.warn("unexpected/unhandled cell in direction", cell)

	var any_move: bool = moves_to_make.any(func(m: Move) -> bool: return m.type == Move.MoveType.move_to)
	if any_move:
		for p: Player in state.players:
			p.move_history.push_front(p.coord)

		for m: Move in moves_to_make:
			if m.type == Move.MoveType.move_to:
				@warning_ignore("unsafe_method_access")
				m.fn.call(m.player, m.cell)

		# trigger HUD update
		player_moved.emit()
		return MoveResult.moved

	var any_undo: bool = moves_to_make.any(func(m: Move) -> bool: return m.type == Move.MoveType.undo)
	if any_undo:
		# consider only undoing ONE time? does it make a difference?
		for m: Move in moves_to_make:
			undo_last_move(m.player)
		return MoveResult.undo

	# trigger HUD update
	move_rejected.emit()

	return MoveResult.stuck
