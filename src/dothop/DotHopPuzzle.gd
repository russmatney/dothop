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
	var scene: PackedScene = opts.get("puzzle_scene", _theme.get_puzzle_scene() if _theme else null)
	if scene == null:
		scene = load(DotHopPuzzle.fallback_puzzle_scene)

	var node: DotHopPuzzle = scene.instantiate()
	node.game_def = _game_def
	node.theme = _theme
	if _theme:
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
var state: PuzzleState

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
	var total_dots: float = float(state.dot_count() + 1)
	var dotted: float = total_dots - float(state.dot_count(true)) - 1
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
		for p: PuzzleState.Player in state.players:
			undo_last_move(p)
		restart_block_move_timer(0.1)

	elif Trolls.is_restart_held(event):
		hold_to_reset_puzzle()
	elif Trolls.is_restart_released(event):
		cancel_reset_puzzle()
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

func reset_pressed() -> void:
	build_game_state()

func undo_pressed() -> void:
	if state == null:
		Log.warn("No state, ignoring undo input")
		return
	for p: PuzzleState.Player in state.players:
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
	var dir := (state.coord_for_dot(dot) - player.coord).normalized()

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
	state = PuzzleState.new(puzzle_def, game_def)
	rebuild_nodes()

# Adds nodes for the object_names in each cell of the grid.
func rebuild_nodes() -> void:
	clear_nodes()

	var players: Array[DotHopPlayer] = []
	for cell: PuzzleState.Cell in state.all_cells():
		var dot_nodes: Array[DotHopDot] = []
		for obj_name: GameDef.Obj in cell.objs:
			var node: Node2D = setup_node_at_coord(obj_name, cell.coord)
			if node is DotHopPlayer:
				state.add_player(cell.coord, node as DotHopPlayer)
				players.append(node)
			elif node is DotHopDot:
				var dot: DotHopDot = node
				dot.dot_pressed.connect(on_dot_pressed.bind(dot))
				dot.mouse_dragged.connect(on_dot_mouse_dragged.bind(dot))
				add_child(dot)
				state.add_dot(cell.coord, dot)
				dot_nodes.append(node)
		state.set_nodes(cell, dot_nodes)

	# wait to add players last (so they end up on top)
	for p: Node in players:
		add_child(p)

	if dhcam != null:
		dhcam.center_on_rect(puzzle_rect({dots_only=true}))

	# trigger HUD update
	rebuilt_nodes.emit()

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
		nodes = state.all_cell_nodes({filter=func(node: DotHopDot) -> bool:
			return "type" in node and node.type in [DHData.dotType.Dot, DHData.dotType.Goal]})
	else:
		nodes = state.all_cell_nodes()
	cam_nodes.append_array(nodes)
	for p: PuzzleState.Player in state.players:
		cam_nodes.append(p.node)
	return cam_nodes


## move/state-updates ##############################################################

# Move the player to the passed cell's coordinate.
# also updates the game state
# cell should have a `coord`
# NOTE updating move_history is done after all players move
func move_player_to_cell(player: PuzzleState.Player, cell: PuzzleState.Cell) -> Signal:
	# move player node
	var move_finished_sig: Signal
	var res: Variant = player.node.move_to_coord(cell.coord)
	if res != null:
		move_finished_sig = res

	# update game state
	state.mark_player(cell.coord)
	state.drop_player(player.coord)

	# remove previous undo marker
	# NOTE start_at 1 b/c history has already been updated
	var prev_undo_coord: Variant
	if len(player.move_history) > 1:
		prev_undo_coord = player.previous_undo_coord(player.coord, 1)
	if prev_undo_coord != null:
		state.drop_undo(prev_undo_coord as Vector2)

	# add new undo marker at current coord
	state.mark_undo(player.coord)

	# update to new coord
	player.coord = cell.coord

	return move_finished_sig

# converts the dot at the cell's coord to a dotted one
# depends on cell for `coord` and `nodes`.
func mark_cell_dotted(cell: PuzzleState.Cell) -> void:
	# support multiple nodes per cell?
	var node: DotHopDot = U.first(cell.nodes)
	if node == null:
		Log.warn("can't mark dotted, no node found!", cell)
		return
	node.mark_dotted()
	state.mark_dotted(cell.coord)

# converts dotted back to dot (undo)
# depends on cell for `coord` and `nodes`.
func mark_cell_undotted(cell: PuzzleState.Cell) -> void:
	# support multiple nodes per cell?
	var node: DotHopDot = U.first(cell.nodes)
	if node == null:
		# undoing from goal doesn't require any undotting
		return
	node.mark_undotted()
	# update game state
	state.mark_undotted(cell.coord)

## move to dot ##############################################################

func move_to_dot(player: PuzzleState.Player, cell: PuzzleState.Cell) -> void:
	# consider handling these in the same step (depending on the animation)
	move_player_to_cell(player, cell)
	mark_cell_dotted(cell)

## move to goal ##############################################################

func move_to_goal(player: PuzzleState.Player, cell: PuzzleState.Cell) -> Signal:
	var move_finished: Signal = move_player_to_cell(player, cell)

	if state.check_win():
		state.win = true
		return move_finished
	else:
		player.stuck = true
		return move_finished

## undo last move ##############################################################

func undo_last_move(player: PuzzleState.Player) -> void:
	# supports the solver - undo moves state.win back to false
	state.win = false

	if len(player.move_history) == 0:
		Log.warn("Can't undo, no moves yet!")
		return
	# remove last move from move_history
	var last_pos: Vector2 = player.move_history.pop_front()
	var dest_cell: PuzzleState.Cell = state.cell_at_coord(last_pos)

	# need to walk back the grid's Undo markers
	var pos_before_last: Variant = player.previous_undo_coord(dest_cell.coord, 0)
	if pos_before_last != null:
		state.mark_undo(pos_before_last as Vector2)
	state.drop_undo(dest_cell.coord)

	if last_pos == player.coord:
		# used in multi-hopper puzzles ('other' player stays in same place when undoing)
		player.node.undo_to_same_coord()
		return

	# move player node
	player.node.undo_to_coord(dest_cell.coord)

	# update game state
	state.mark_player(dest_cell.coord)
	state.drop_player(player.coord)

	if state.is_coord_dotted(player.coord):
		# restore dot at the current player position
		mark_cell_undotted(state.cell_at_coord(player.coord))
	if state.is_coord_goal(player.coord):
		# unstuck when undoing from the goal
		player.stuck = false

	# update state player position
	player.coord = dest_cell.coord

## move ##############################################################

func apply_moves(move_dir: Vector2, moves_to_make: Array[PuzzleState.Move]) -> PuzzleState.MoveResult:
	var any_move: bool = moves_to_make.any(func(m: PuzzleState.Move) -> bool:
		return m.type in [PuzzleState.MoveType.move_to_dot, PuzzleState.MoveType.move_to_goal])
	if any_move:
		for p: PuzzleState.Player in state.players:
			p.move_history.push_front(p.coord)

		for m: PuzzleState.Move in moves_to_make:
			# TODO consider influencing these moves with any Move.dots-to-hop

			if m.type == PuzzleState.MoveType.move_to_dot:
				move_to_dot(m.player, m.cell)
			if m.type == PuzzleState.MoveType.move_to_goal:
				move_to_goal(m.player, m.cell)

		# trigger HUD update
		player_moved.emit()

		if state.win:
			# TODO i think we wait to emit this? check_win elsewhere?
			# at least wait until the player animation is done... unless we should have a different one
			win.emit()
		return PuzzleState.MoveResult.moved

	var any_undo: bool = moves_to_make.any(func(m: PuzzleState.Move) -> bool: return m.type == PuzzleState.MoveType.undo)
	if any_undo:
		# consider only undoing ONE time? does it make a difference?
		for m: PuzzleState.Move in moves_to_make:
			if m.type == PuzzleState.MoveType.undo:
				undo_last_move(m.player)

				player_undo.emit()
		# exit early for undos
		return PuzzleState.MoveResult.undo

	var any_stuck: bool = moves_to_make.any(func(m: PuzzleState.Move) -> bool:
		return m.type in [
			PuzzleState.MoveType.stuck, PuzzleState.MoveType.hop_a_dot,
			])
	if any_stuck:
		for m: PuzzleState.Move in moves_to_make:
			if m.type == PuzzleState.MoveType.stuck:
				m.player.node.move_attempt_stuck(move_dir)
			if m.type == PuzzleState.MoveType.hop_a_dot:
				# reusing the stuck behavior here
				m.player.node.move_attempt_stuck(move_dir)

	# trigger HUD update
	move_rejected.emit()

	return PuzzleState.MoveResult.stuck

func move(move_dir: Vector2) -> PuzzleState.MoveResult:
	if move_dir == Vector2.ZERO:
		# don't do anything!
		return PuzzleState.MoveResult.zero
	if not move_dir in ALLOWED_MOVES:
		return PuzzleState.MoveResult.move_not_allowed

	var moves_to_make := state.check_move(move_dir)
	# Log.prn("moves to make", moves_to_make)
	return apply_moves(move_dir, moves_to_make)
