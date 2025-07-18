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
	var _puzzle_def: PuzzleDef = opts.get("puzzle_def")
	var _theme: PuzzleTheme = opts.get("puzzle_theme")

	if _puzzle_def == null or _puzzle_def.shape == null:
		Log.error("Couldn't build puzzle node, no puzzle_def passed", opts)
		return

	var scene: PackedScene = _theme.get_puzzle_scene()
	var node: DotHopPuzzle = scene.instantiate()

	node.theme_data = _theme.get_theme_data()
	node.puzzle_def = _puzzle_def
	return node

## vars ##############################################################

@export_tool_button("Clear") var clear_action: Callable = clear_nodes
@export_tool_button("Play Intro") var trigger_intro: Callable =\
	Anim.puzzle_animate_intro_from_point.bind(self, min_t, max_t)
@export_tool_button("Play Outro") var trigger_outro: Callable =\
	Anim.puzzle_animate_outro_to_point.bind(self)

@export var min_t : float = 0.1
@export var max_t : float = 1.0
@export var debugging: bool = false
@export var square_size: int = 32

var puzzle_def: PuzzleDef
var theme_data: PuzzleThemeData

var dhcam: DotHopCam
var state: PuzzleState
# apparently used in Anim?
var player_nodes: Array = []

signal win

# hud updates
signal player_moved
signal player_undo
signal move_rejected
signal move_input_blocked
signal rebuilt_nodes

# fallbacks
@export var fallback_puzzle_set_data: PuzzleSetData
@export var fallback_puzzle_def: int = 0

## enter_tree ##############################################################

func _init() -> void:
	add_to_group(DHData.puzzle_group, true)

## ready ##############################################################

@export var randomize_layout: bool = true

func _ready() -> void:
	if puzzle_def == null:
		# TODO fetch from the PuzzleStore? do we even need a fallback?
		puzzle_def = fallback_puzzle_set_data.puzzle_defs[0]
		Log.warn("No puzzle_def set, using fallback", puzzle_def)

	if puzzle_def == null:
		Log.error("no puzzle_def!", name)
		return

	# a Log-based validation warning would be nice
	# maybe Log.gd's direction is toward a godot-devlog-companion
	# e.g. Log.ensure(theme_data, "Puzzle Scene running with no theme data!")
	if theme_data == null:
		Log.warn("Puzzle Scene running with no theme data!")

	if randomize_layout:
		puzzle_def.shuffle_puzzle_layout()

	build_game_state()

	# fallback cam setup for running this scene directly
	if not Engine.is_editor_hint() and is_inside_tree():
		dhcam = DotHopCam.ensure_camera(self)

	input_block_timer_done.connect(reattempt_blocked_move)

	# ideally this would fire after the nodes are ready
	# prolly a race-case here
	state.emit_possible_cells.call_deferred()

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
		undo_last_move()
		restart_block_move_timer(0.1)

	elif Trolls.is_restart_held(event):
		hold_to_reset_puzzle()
	elif Trolls.is_restart_released(event):
		cancel_reset_puzzle()
	elif Trolls.is_shuffle(event):
		shuffle_pressed()
	# elif Trolls.is_debug_toggle(event):
	# 	Log.pr(state.grid)

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

## actions ##############################################################

func shuffle_pressed() -> void:
	puzzle_def.shuffle_puzzle_layout()
	build_game_state()

func reset_pressed() -> void:
	build_game_state()

func undo_pressed() -> void:
	if state == null:
		Log.warn("No state, ignoring undo input")
		return
	undo_last_move()

func dot_pressed(node: DotHopDot) -> void:
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
		for obj: GameDef.Obj in cell.objs:
			if obj in [GameDef.Obj.Dot, GameDef.Obj.Goal, GameDef.Obj.Dotted]:
				var dot: DotHopDot = setup_node_at_coord(obj, cell.coord)
				connect_dot_signals(dot, cell, obj)
				add_child(dot)
			else:
				if not obj in [GameDef.Obj.Player, GameDef.Obj.Undo]:
					Log.warn("skipping setup for unhandled obj: ", obj)

	player_nodes = []
	for p: PuzzleState.Player in state.players:
		var p_node: DotHopPlayer = setup_node_at_coord(GameDef.Obj.Player, p.coord)
		connect_player_signals(p_node, p)
		add_child(p_node) # add players after dots for z-indexing
		player_nodes.append(p_node)

	if dhcam != null:
		dhcam.center_on_rect(puzzle_rect({dots_only=true}))

	# trigger HUD update, etc
	rebuilt_nodes.emit()

# TODO i suspect alot of this setup/connect can move to a Dot.gd node _ready() impl
func connect_dot_signals(dot: DotHopDot, cell: PuzzleState.Cell, _obj: GameDef.Obj) -> void:
	dot.dot_pressed.connect(dot_pressed.bind(dot))
	dot.mouse_dragged.connect(on_dot_mouse_dragged.bind(dot))

	cell.mark_dotted.connect(func() -> void: dot.mark_dotted())
	cell.mark_undotted.connect(func() -> void: dot.mark_undotted())
	cell.show_possible_next_move.connect(func() -> void: dot.show_possible_next_move())
	cell.show_possible_undo.connect(func() -> void: dot.show_possible_undo())
	cell.remove_possible_next_move.connect(func() -> void: dot.remove_possible_next_move())

func connect_player_signals(p_node: DotHopPlayer, p_state: PuzzleState.Player) -> void:
	# setup state player signals
	p_state.move_to_cell.connect(func(cell: PuzzleState.Cell) -> void: p_node.move_to_coord(cell.coord))
	p_state.undo_to_cell.connect(func(cell: PuzzleState.Cell) -> void: p_node.undo_to_coord(cell.coord))
	p_state.undo_to_same_cell.connect(func(_cell: PuzzleState.Cell) -> void: p_node.undo_to_same_coord())
	p_state.move_attempt_stuck.connect(func(dir: Vector2) -> void: p_node.move_attempt_stuck(dir))

	# connect to move finished signal
	# we might want to track out-standing moves here, rather than just checking on one
	p_node.move_finished.connect(func() -> void: player_move_finished())


func setup_node_at_coord(obj_type: GameDef.Obj, coord: Vector2) -> Node:
	var node: Node2D = node_for_object_name(obj_type)
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

func node_for_object_name(obj_type: GameDef.Obj) -> Node2D:
	var scene: PackedScene = get_scene_for(obj_type)
	if not scene:
		Log.err("No scene found for object name", obj_type)
		return
	var node: Node2D = scene.instantiate()
	if node is DotHopDot:
		var dot: DotHopDot = node
		dot.display_name = GameDef.reverse_obj_map[obj_type]
		dot.type = to_dot_type.get(obj_type)
	if node is DotHopPlayer:
		var p: DotHopPlayer = node
		p.display_name = GameDef.reverse_obj_map[obj_type]
	return node

var to_dot_type: Dictionary = {
	GameDef.Obj.Dot: DHData.dotType.Dot,
	GameDef.Obj.Dotted: DHData.dotType.Dotted,
	GameDef.Obj.Goal: DHData.dotType.Goal,
	}

func get_scene_for(obj_name: GameDef.Obj) -> PackedScene:
	match obj_name:
		GameDef.Obj.Player: return PuzzleThemeData.get_player_scene(theme_data)
		GameDef.Obj.Dot: return PuzzleThemeData.get_dot_scene(theme_data)
		GameDef.Obj.Dotted: return PuzzleThemeData.get_dotted_scene(theme_data)
		GameDef.Obj.Goal: return PuzzleThemeData.get_goal_scene(theme_data)
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
	if len(nodes) == 0:
		Log.error("No puzzle nodes found, cannot calc puzzle Rect!")
		return Rect2()
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
		nodes = all_dot_nodes({filter=func(node: DotHopDot) -> bool:
			return node.type in [DHData.dotType.Dot, DHData.dotType.Goal]})
	else:
		nodes = all_dot_nodes()
	cam_nodes.append_array(nodes)
	return cam_nodes

func all_dot_nodes(opts: Dictionary = {}) -> Array:
	var dots: Array = U.get_children_in_group(self, "dot", true)
	if "filter" in opts:
		var f: Callable = opts.get("filter")
		dots = dots.filter(f)
	return dots

## move ##############################################################

const ALLOWED_MOVES := [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

func move(move_dir: Vector2) -> PuzzleState.MoveResult:
	if not move_dir in ALLOWED_MOVES:
		return PuzzleState.MoveResult.move_not_allowed

	var move_result := state.move(move_dir)

	match move_result:
		PuzzleState.MoveResult.moved:
			player_moved.emit()
		PuzzleState.MoveResult.undo:
			player_undo.emit()
		PuzzleState.MoveResult.stuck:
			move_rejected.emit()

	return move_result

# Fires when the player move_to_coord animation finishes
# NOTE this does NOT fire on undos or stucks
func player_move_finished() -> void:
	if state.win:
		# TODO fires too early rn if you move quickly
		win.emit()

# TODO could dry up to use apply_moves and the response here
# but if we subscribe to signals, maybe those will just get emitted,
# and this doesn't need to do anything?
func undo_last_move() -> void:
	for p: PuzzleState.Player in state.players:
		state.undo_last_move(p)
	player_undo.emit()
