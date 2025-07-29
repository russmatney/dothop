@tool
extends Node2D
class_name DotHopPuzzle

## static ##########################################################################

static var fallback_puzzle_scene: String = "res://src/dothop/DotHopPuzzle.tscn"
static var fallback_theme_data: String = "res://src/themes/DebugThemeData.tres"

static func test_puzzle_node(puzzle: Array) -> DotHopPuzzle:
	var scene: PackedScene = load(DotHopPuzzle.fallback_puzzle_scene)
	var node: DotHopPuzzle = scene.instantiate()

	node.theme_data = load(fallback_theme_data)
	node.puzzle_def = PuzzleDef.parse(puzzle)
	return node

static func build_puzzle_node(opts: Dictionary) -> DotHopPuzzle:
	var puzz_def: PuzzleDef = opts.get("puzzle_def")
	var puzz_num: int = opts.get("puzzle_num", -1)
	var wrd: PuzzleWorld = opts.get("world")
	var theme_dt: PuzzleThemeData = opts.get("theme_data")
	if theme_dt == null and wrd:
		theme_dt = wrd.get_theme_data()

	if puzz_def == null or puzz_def.shape == null:
		Log.error("Couldn't build puzzle node, no puzzle_def passed", opts)
		return

	var scene: PackedScene
	if wrd:
		scene = wrd.get_puzzle_scene()
	elif theme_dt:
		scene = theme_dt.puzzle_scene

	var node: DotHopPuzzle
	if scene:
		node = scene.instantiate()
	else:
		node = DotHopPuzzle.new()

	node.world = wrd
	node.theme_data = theme_dt
	node.puzzle_def = puzz_def
	node.puzzle_num = puzz_num
	return node

# i need 27 unit tests for this mofo
static func rebuild_puzzle(opts: Dictionary = {}) -> DotHopPuzzle:
	var puzz_num: int = opts.get("puzzle_num", -1)
	var puzzle_node: DotHopPuzzle = opts.get("puzzle_node")
	var container: Node = opts.get("container", puzzle_node.get_parent() if puzzle_node else null)
	var wrld: PuzzleWorld = opts.get("world")
	var theme_dt: PuzzleThemeData = opts.get("theme_data")
	var puzz_def: PuzzleDef = opts.get("puzzle_def")

	if container == null and puzzle_node == null:
		Log.warn("Invalid opts passed to rebuild_puzzle, requires either container or an existing puzzle_node", opts)

	if puzzle_node != null:
		if theme_dt == null:
			if wrld != null:
				# prefer to get theme data from the passed world
				theme_dt = wrld.get_theme_data()
		if wrld == null:
			wrld = puzzle_node.world
		if puzz_num == -1:
			puzz_num = puzzle_node.puzzle_num # or puzz_def.idx?
		if theme_dt == null:
			# still no theme? use the existing puzzle_node
			theme_dt = puzzle_node.theme_data
		if container == null:
			container = puzzle_node.get_parent()

		for cb: Callable in puzzle_node.pre_remove_hooks:
			if cb.is_null() or not cb.is_valid():
				continue
			var val: Variant = cb.call()
			if val is Signal:
				await val

		if container:
			container.remove_child(puzzle_node)
		puzzle_node.queue_free()
	else:
		# no puzzle_node, fix defaults
		if puzz_num == -1:
			puzz_num = 0
		if theme_dt == null and wrld != null:
			theme_dt = wrld.get_theme_data()
	if puzz_def == null and wrld != null and puzz_num != -1:
		puzz_def = wrld.get_puzzles()[puzz_num]
	if puzz_def == null and puzzle_node:
		puzz_def = puzzle_node.puzzle_def

	U.ensure_default(opts, "world", wrld)
	U.ensure_default(opts, "puzzle_def", puzz_def)
	U.ensure_default(opts, "puzzle_num", puzz_num)
	U.ensure_default(opts, "theme_data", theme_dt)

	# build puzzle node
	puzzle_node = DotHopPuzzle.build_puzzle_node(opts)

	# add to container
	container.add_child.call_deferred(puzzle_node)

	return puzzle_node

## vars ##############################################################

var world: PuzzleWorld
var puzzle_def: PuzzleDef
var puzzle_num: int # can this live on PuzzleDef? should it? it's a puzzle-set thing?
var theme_data: PuzzleThemeData

var pre_remove_hooks: Array[Callable] = []
func add_pre_remove_hook(cb: Callable) -> void:
	pre_remove_hooks.append(cb)

var state: PuzzleState
# apparently used in Anim?
var player_nodes: Array = []

signal player_moved
signal player_undo
signal move_rejected
signal move_input_blocked
signal rebuilt_nodes

# fallbacks
@export var fallback_world: PuzzleWorld

## enter_tree ##############################################################

func _init() -> void:
	add_to_group(DHData.puzzle_group, true)

## ready ##############################################################

@export var randomize_layout: bool = true

func _ready() -> void:
	if puzzle_def == null:
		# TODO fetch from the PuzzleStore? do we even need a fallback?
		var pzs: Array[PuzzleDef] = PuzzleStore.get_puzzles()
		if len(pzs) > 0:
			puzzle_def = pzs[0]
			Log.info("No puzzle_def set, using fallback", puzzle_def)
		else:
			Log.error("No puzzle_def set!", name)
			return

	# a Log-based validation warning would be nice
	# maybe Log.gd's direction is toward a godot-devlog-companion
	# e.g. Log.ensure(theme_data, "Puzzle Scene running with no theme data!")
	if theme_data == null:
		if fallback_world:
			Log.warn("No theme_data set, using fallback")
			theme_data = fallback_world.get_theme_data()
		else:
			Log.warn("Puzzle Scene running with no theme data!")

	if randomize_layout:
		puzzle_def.shuffle_puzzle_layout()

	build_game_state()

	input_block_timer_done.connect(reattempt_blocked_move)

	# ideally this would fire after the nodes are ready
	# prolly a race-case here
	state.emit_possible_cells.call_deferred()

	Events.puzzle_node.fire_puzzle_node_ready.call_deferred(self)
	tree_exiting.connect(Events.puzzle_node.fire_puzzle_node_exiting.bind(self))

	Events.puzzle_node.change_theme.connect(func(evt: Events.Evt) -> void:
		on_change_theme(evt.theme_data), CONNECT_ONE_SHOT)

func on_change_theme(theme: PuzzleThemeData) -> void:
	# full node recreation?
	DotHopPuzzle.rebuild_puzzle({puzzle_node=self, theme_data=theme})

	# or swap in-place? Doesn't work yet! Nearly tho.
	# theme_data = theme
	# rebuild_nodes()

## actions ##############################################################

func shuffle_pressed() -> void:
	Log.info("[PuzzleAction]", "SHUFFLE")
	puzzle_def.shuffle_puzzle_layout()
	build_game_state()

func reset_pressed() -> void:
	# TODO signal (for e.g. subtracting lives)
	Log.info("[PuzzleAction]", "RESET")
	build_game_state()

func undo_pressed() -> void:
	# TODO signal (for e.g. for subtracting health)
	Log.info("[PuzzleAction]", "UNDO")
	if state == null:
		Log.warn("No state, ignoring undo input")
		return
	undo_last_move()

func dot_pressed(node: DotHopDot) -> void:
	# TODO support multiple players properly
	# smthg like check_moves() for all possible player move directions

	# calc move_vec for tapped dot with first player
	var first_player_coord: Variant
	for p: PuzzleState.Player in state.players:
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

## move ##############################################################

const ALLOWED_MOVES := [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

func move(move_dir: Vector2) -> PuzzleState.MoveResult:
	if not move_dir in ALLOWED_MOVES:
		return PuzzleState.MoveResult.move_not_allowed

	# emits a bunch of signals on state.players and state.cells
	# (which player/dot nodes attach to)
	var move_result := state.move(move_dir)

	match move_result:
		PuzzleState.MoveResult.moved:
			player_moved.emit()
		PuzzleState.MoveResult.undo:
			player_undo.emit()
		PuzzleState.MoveResult.stuck:
			move_rejected.emit()

	return move_result

# Fired when the player move_to_coord animation finishes
# NOTE this does NOT fire on undos or stucks
func player_move_finished() -> void:
	if state.win:
		Events.puzzle_node.fire_win(self)

# TODO could dry up to use apply_moves and the response here
# but if we subscribe to signals, maybe those will just get emitted,
# and this doesn't need to do anything?
func undo_last_move() -> void:
	for p: PuzzleState.Player in state.players:
		state.undo_last_move(p)
	player_undo.emit()

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
	var player: PuzzleState.Player = state.players[0]
	var dir := (dot.current_coord - player.coord).normalized()

	if dir == Vector2.ZERO:
		move_queue.pop_front()
		# loop! until early exit
		process_move_queue(true)
		return

	var res: Variant = attempt_move(dir)
	if res is bool and res == false:
		Log.info("No move made, is input blocked?")
	elif res in [PuzzleState.MoveResult.stuck, PuzzleState.MoveResult.zero, PuzzleState.MoveResult.move_not_allowed, PuzzleState.MoveResult.undo]:
		# TODO shake the unreachable dot!
		move_queue.pop_front()
		last_dot_dragged = null
	elif res in [PuzzleState.MoveResult.moved]:
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
	state = PuzzleState.new(puzzle_def)
	rebuild_nodes()

# (Re)Creates dot and player nodes, attaches state signals
func rebuild_nodes() -> void:
	clear_nodes()

	for cell: PuzzleState.Cell in state.all_cells():
		for obj: DHData.Obj in cell.objs:
			if obj in [DHData.Obj.Dot, DHData.Obj.Goal, DHData.Obj.Dotted]:
				var dot := DotHopDot.setup_dot(obj, cell, state.players, theme_data)
				# connect dot interaction inputs
				dot.add_to_group("generated", true)
				dot.dot_pressed.connect(dot_pressed.bind(dot))
				dot.mouse_dragged.connect(on_dot_mouse_dragged.bind(dot))
				add_child(dot)
			else:
				if not obj in [DHData.Obj.Player, DHData.Obj.Undo]:
					Log.warn("skipping setup for unhandled obj: ", obj)

	player_nodes = []
	for p: PuzzleState.Player in state.players:
		# TODO setup_player_at_coord
		var p_node := DotHopPlayer.setup_player(p, theme_data)
		p_node.add_to_group("generated", true)
		connect_player_signals(p_node, p)
		add_child(p_node) # add players after dots for z-indexing
		player_nodes.append(p_node)

	# trigger HUD, camera, etc updates
	rebuilt_nodes.emit()

var inflight_player_moves := 0
func connect_player_signals(p_node: DotHopPlayer, p_state: PuzzleState.Player) -> void:
	# setup state player signals
	p_state.move_to_cell.connect(func(_cell: PuzzleState.Cell) -> void:
		inflight_player_moves += 1)

	# connect to move finished signal
	# we might want to track out-standing moves here, rather than just checking on one
	p_node.move_finished.connect(func() -> void:
		inflight_player_moves -= 1
		if inflight_player_moves <= 0:
			# defer b/c move_finished is emitted before state.win is set?!
			player_move_finished.call_deferred())

## misc utils ##############################################################

func clear_nodes() -> void:
	for ch: Variant in get_children():
		if not ch is CanvasItem:
			continue
		var ci: CanvasItem = ch as CanvasItem
		if ci.is_in_group("generated"):
			# hide flicker while we wait for queue_free
			ci.set_visible(false)
			ci.queue_free()

func all_dot_nodes() -> Array[DotHopDot]:
	var dots: Array[DotHopDot] = []
	dots.assign(U.get_children_in_group(self, "dot", true))
	return dots

func puzzle_rect() -> Rect2:
	var dots := all_dot_nodes()
	dots = dots.filter(func(node: DotHopDot) -> bool:
			return node.type in [DHData.dotType.Dot, DHData.dotType.Goal])
	if len(dots) == 0:
		return Rect2()

	var rect: Rect2 = Rect2(dots[0].current_position(), Vector2.ZERO)
	for dot: DotHopDot in dots:
		# scale might also be a factor
		var bot_right: Vector2 = dot.current_position() + dot.square_size * Vector2.ONE * 1.0
		# why the half here?
		var top_left_half: Vector2 = dot.current_position() - dot.square_size * Vector2.ONE * 0.5
		rect = rect.expand(bot_right).expand(top_left_half)
	return rect
