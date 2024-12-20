@tool
extends Node2D
class_name DotHopPuzzle

## static ##########################################################################

static var fallback_puzzle_scene = "res://src/puzzle/PuzzleScene.tscn"

# Builds and returns a "puzzle_scene" node, with a game_def and puzzle_def set
# Accepts several input options, but only 'game_def' or 'game_def_path' are required.
#
# A raw puzzle or puzzle_num can be specified to load/pick a puzzle for a particular game_def.
# `puzzle_scene` should be set according to the current theme.
#
# This func could live on the DotHopGame script, but a function like this is useful
# for testing just the game logic (without loading a full DotHopGame)
static func build_puzzle_node(opts:Variant) -> Node2D:
	# parse the puzzle script game, set game_def
	var game_def_p = opts.get("game_def_path")
	var _game_def = opts.get("game_def")
	if not _game_def and game_def_p:
		_game_def = Puzz.parse_game_def(game_def_p)

	if _game_def == null:
		Log.warn("No game_def passed, cannot build_puzzle_node()", opts)
		return

	# parse/pick the puzzle to load
	var puzzle = opts.get("puzzle")
	# default to loading the first puzzle
	var _puzzle_num = opts.get("puzzle_num", 0)
	var _puzzle_def: PuzzleDef

	if puzzle != null:
		_puzzle_def = Puzz.parse_puzzle_def(puzzle)
	elif _puzzle_num != null:
		_puzzle_def = _game_def.puzzles[_puzzle_num]
	else:
		pass

	if _puzzle_def == null or _puzzle_def.shape == null:
		Log.warn("Could not determine _puzzle_def, cannot build_puzzle_node()")
		return

	var _theme = opts.get("puzzle_theme")
	var scene = opts.get("puzzle_scene", _theme.get_puzzle_scene() if _theme else null)
	if scene is String:
		scene = load(scene)
	elif scene == null:
		scene = load(fallback_puzzle_scene)

	var node = scene.instantiate()

	node.game_def = _game_def
	node.theme = _theme
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
var game_def : GameDef
var puzzle_def : PuzzleDef :
	set(ld):
		puzzle_def = ld
		if Engine.is_editor_hint():
			init_game_state()
@export var square_size = 32

@export var puzzle_num : int :
	set(pn):
		puzzle_num = pn
		if Engine.is_editor_hint():
			if game_def:
				puzzle_def = game_def.puzzles[pn]


var state

signal win

# hud updates
signal player_moved
signal player_undo
signal move_rejected
signal move_blocked
signal rebuilt_nodes

var obj_type = {
	"Dot": DHData.dotType.Dot,
	"Dotted": DHData.dotType.Dotted,
	"Goal": DHData.dotType.Goal,
	}

## enter_tree ##############################################################

func _init():
	add_to_group(DHData.puzzle_group, true)

## ready ##############################################################

@export var randomize_layout = true
var reverse_ys = false
var reverse_xs = false
var rotate_shape = false

func _ready():
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
			for row in puzzle_def.shape:
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

func on_win():
	Sounds.play(Sounds.S.complete)

func on_player_moved():
	var total_dots = float(dot_count() + 1)
	var dotted = total_dots - float(dot_count(true)) - 1
	# ensure some minimum
	dotted = clamp(dotted, total_dots/4, total_dots)
	if state.win:
		dotted += 1
	Sounds.play(Sounds.S.dot_collected, {scale_range=total_dots, scale_note=dotted, interrupt=true})

func on_player_undo():
	Sounds.play(Sounds.S.minimize)

func on_move_rejected():
	Sounds.play(Sounds.S.showjumbotron)

func on_move_blocked():
	pass

func on_rebuilt_nodes():
	Sounds.play(Sounds.S.maximize)


## input ##############################################################

var just_logged_blocked_input = false
func _unhandled_input(event):
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
		for p in state.players:
			undo_last_move(p)
		restart_block_move_timer(0.1)

	elif Trolls.is_restart_held(event):
		hold_to_reset_puzzle()
	elif Trolls.is_restart_released(event):
		cancel_reset_puzzle()
	elif Trolls.is_debug_toggle(event):
		Log.pr(state.grid)

var reset_tween
func hold_to_reset_puzzle():
	if reset_tween != null and reset_tween.is_running():
		# already holding
		return
	reset_tween = create_tween()
	reset_tween.tween_callback(init_game_state).set_delay(DHData.reset_hold_t)

func cancel_reset_puzzle():
	if reset_tween == null:
		return
	reset_tween.kill()

func reset_pressed():
	init_game_state()

func undo_pressed():
	if state == null:
		Log.warn("No state, ignoring undo input")
		return
	for p in state.players:
		undo_last_move(p)


## check_move_input ##############################################################

var block_move
var last_move

func check_move_input(event=null, move_vec=null):
	if move_vec == null:
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

var block_move_timer
func restart_block_move_timer(t=0.2):
	block_move = true
	if block_move_timer != null:
		block_move_timer.kill()
	block_move_timer = create_tween()
	block_move_timer.tween_callback(func():
		block_move = false
		check_move_input()).set_delay(t)

func on_dot_pressed(_type, node):
	# calc move_vec for tapped dot with first player
	var first_player_coord = null
	for p in state.players:
		if p.coord != null:
			first_player_coord = p.coord
			break
	if first_player_coord == null:
		Log.warn("Cannot move to dot, no player coord found")
		return

	var move_vec = node.current_coord - first_player_coord
	if move_vec.x == 0 or move_vec.y == 0:
		check_move_input(null, move_vec.normalized())
	else:
		Log.info("Cannot move to dot", node, node.current_coord)


## state/grid ##############################################################

# sets up the state grid and some initial data based on the assigned puzzle_def
func init_game_state():
	if len(puzzle_def.shape) == 0:
		Log.warn("init_game_state() called without puzzle_def.shape", puzzle_def)
		return

	var grid = []
	var players = []
	for y in len(puzzle_def.shape):
		var row = puzzle_def.shape[y]
		var r = []
		for x in len(row):
			var cell = puzzle_def.shape[y][x]
			var objs = game_def.get_cell_objects(cell)
			r.append(objs)
		grid.append(r)

	state = {players=players, grid=grid, grid_xs=len(grid[0]), grid_ys=len(grid), win=false, cell_nodes={}}

	rebuild_nodes()


## setup level ##############################################################

func init_player(coord, node) -> Dictionary:
	return {coord=coord, stuck=false, move_history=[], node=node}

func clear_nodes():
	for ch in get_children():
		if ch.is_in_group("generated"):
			# hide flicker while we wait for queue_free
			ch.set_visible(false)
			ch.queue_free()

var dhcam_scene = preload("res://src/DotHopCam.tscn")
var dhcam
func ensure_camera():
	if len(state.grid) == 0:
		return

	dhcam = get_node_or_null("DotHopCam")
	if dhcam == null:
		dhcam = get_parent().get_node_or_null("DotHopCam")
	if dhcam == null:
		dhcam = dhcam_scene.instantiate()
		add_child(dhcam)

func coord_pos(node):
	if node.has_method("current_position"):
		return node.current_position()
	else:
		return node.position

func puzzle_rect(opts={}):
	var nodes = puzzle_cam_nodes(opts)
	var rect = Rect2(coord_pos(nodes[0]), Vector2.ZERO)
	for node in nodes:
		if "square_size" in node:
			# scale might also be a factor
			rect = rect.expand(coord_pos(node) + node.square_size * Vector2.ONE * 1.0)
			rect = rect.expand(coord_pos(node) - node.square_size * Vector2.ONE * 0.5)
		else:
			rect = rect.expand(coord_pos(node))
	return rect

func puzzle_cam_nodes(opts={}):
	var cam_nodes = []
	var nodes
	if opts.get("dots_only"):
		nodes = all_cell_nodes({filter=func(node):
			return "type" in node and node.type in [DHData.dotType.Dot, DHData.dotType.Goal]})
	else:
		nodes = all_cell_nodes()
	cam_nodes.append_array(nodes)
	for p in state.players:
		cam_nodes.append(p.node)
	return cam_nodes

# Adds nodes for the object_names in each cell of the grid.
# Tracks nodes (except for players) in a state.cell_nodes dict.
# Tracks players in state.players list.
func rebuild_nodes():
	clear_nodes()

	if not Engine.is_editor_hint() and is_inside_tree():
		ensure_camera()

	var players = []
	for y in len(state.grid):
		for x in len(state.grid[y]):
			var objs = state.grid[y][x]
			if objs == null:
				continue
			for obj_name in objs:
				var coord = Vector2(x, y)
				var node = create_node_at_coord(obj_name, coord)
				if obj_name == "Player":
					state.players.append(init_player(coord, node))
					players.append(node)
				else:
					add_child(node)
					if not coord in state.cell_nodes:
						state.cell_nodes[coord] = []
					state.cell_nodes[coord].append(node)

	for p in players:
		add_child(p)

	if dhcam != null:
		dhcam.center_on_rect(puzzle_rect({dots_only=true}))

	# trigger HUD update
	rebuilt_nodes.emit()

func create_node_at_coord(obj_name:String, coord:Vector2) -> Node:
	var node = node_for_object_name(obj_name)
	# nodes should maybe set their own position
	# (i.e. not be automatically moved, but stay on teh puzzle's origin)
	node.square_size = square_size
	if node.has_method("set_initial_coord"):
		node.set_initial_coord(coord)
	else:
		node.position = coord * square_size
	node.add_to_group("generated", true)
	if debugging or not Engine.is_editor_hint():
		node.ready.connect(func():
			node.set_owner(self))
	return node

func node_for_object_name(obj_name):
	var scene = get_scene_for(obj_name)
	if not scene:
		Log.err("No scene found for object name", obj_name)
		return
	var node = scene.instantiate()
	node.display_name = obj_name
	var t = obj_type.get(obj_name)
	if t != null and "type" in node:
		node.type = t
		if node.has_signal("dot_pressed"):
			node.dot_pressed.connect(on_dot_pressed.bind(t, node))
	elif obj_name not in ["Player"]:
		Log.warn("no type for object?", obj_name)
	return node

## custom nodes ##############################################################

func get_scene_for(obj_name):
	match obj_name:
		"Player": return get_player_scene()
		"Dot": return get_dot_scene()
		"Dotted": return get_dotted_scene()
		"Goal": return get_goal_scene()

func get_player_scene():
	if theme and len(theme.get_player_scenes()) > 0:
		return U.rand_of(theme.get_player_scenes())
	return load("res://src/puzzle/Player.tscn")

func get_dot_scene():
	if theme and len(theme.get_dot_scenes()) > 0:
		return U.rand_of(theme.get_dot_scenes())
	return load("res://src/puzzle/Dot.tscn")

func get_dotted_scene():
	if theme and len(theme.get_dot_scenes()) > 0:
		return U.rand_of(theme.get_dot_scenes())
	return load("res://src/puzzle/Dot.tscn")

func get_goal_scene():
	if theme and len(theme.get_goal_scenes()) > 0:
		return U.rand_of(theme.get_goal_scenes())
	return load("res://src/puzzle/Dot.tscn")

## grid helpers ##############################################################

# returns true if the passed coord is in the level's grid
func coord_in_grid(coord:Vector2) -> bool:
	return coord.x >= 0 and coord.y >= 0 and \
		coord.x < state.grid_xs and coord.y < state.grid_ys

func cell_at_coord(coord:Vector2) -> Dictionary:
	var nodes = state.cell_nodes.get(coord)
	return {objs=state.grid[coord.y][coord.x], coord=coord, nodes=nodes}

# returns a list of cells from the passed position in the passed direction
# the cells are dicts with a coord, a list of objs (string names), and a list of nodes
func cells_in_direction(coord:Vector2, dir:Vector2) -> Array:
	if dir == Vector2.ZERO:
		return []
	var cells = []
	var cursor = coord + dir
	var last_cursor = null
	while coord_in_grid(cursor) and last_cursor != cursor:
		cells.append(cell_at_coord(cursor))
		last_cursor = cursor
		cursor += dir
	return cells

# Returns a list of cell object names
func all_cells() -> Array[Variant]:
	if state == null:
		return []
	var cs = []
	for row in state.grid:
		for cell in row:
			cs.append(cell)
	return cs

# Returns true if there are no "dot" objects in the state grid
func all_dotted() -> bool:
	return all_cells().all(func(c):
		if c == null:
			return true
		for obj_name in c:
			if obj_name == "Dot":
				return false
		return true)

func dot_count(only_undotted=false):
	return len(all_cells().filter(func(c):
		if c == null:
			return false
		for obj_name in c:
			if only_undotted and obj_name in ["Dot"]:
				return true
			elif not only_undotted and obj_name in ["Dot", "Dotted"]:
				return true
		return false))


func all_players_at_goal() -> bool:
	return all_cells().filter(func(c):
		if c != null and "Goal" in c:
			return true
		).all(func(c): return "Player" in c)

func all_cell_nodes(opts={}) -> Array[Node2D]:
	var ns = state.cell_nodes.values().reduce(func(agg, nodes):
		if "filter" in opts:
			nodes = nodes.filter(opts.get("filter"))
		agg.append_array(nodes)
		return agg, []) # if we don't provide an initial val, the first node gets through FOR FREE
	var t_nodes: Array[Node2D] = []
	t_nodes.assign(ns)
	return t_nodes

## move/state-updates ##############################################################

func previous_undo_coord(player, skip_coord, start_at=0):
	# pulls the first coord from player history that does not match `skip_coord`,
	# starting after `start_at`
	for m in player.move_history.slice(start_at):
		if m != skip_coord:
			return m

# Move the player to the passed cell's coordinate.
# also updates the game state
# cell should have a `coord`
# NOTE updating move_history is done after all players move
func move_player_to_cell(player, cell):
	# move player node
	var move_finished_sig
	if player.node.has_method("move_to_coord"):
		move_finished_sig = player.node.move_to_coord(cell.coord)
	else:
		player.node.position = cell.coord * square_size

	# update game state
	state.grid[cell.coord.y][cell.coord.x].append("Player")
	state.grid[player.coord.y][player.coord.x].erase("Player")

	# remove previous undo marker
	# NOTE start_at 1 b/c history has already been updated
	var prev_undo_coord
	if len(player.move_history) > 1:
		prev_undo_coord = previous_undo_coord(player, player.coord, 1)
	if prev_undo_coord != null:
		state.grid[prev_undo_coord.y][prev_undo_coord.x].erase("Undo")

	# add new undo marker at current coord
	state.grid[player.coord.y][player.coord.x].append("Undo")

	# update to new coord
	player.coord = cell.coord

	return move_finished_sig

# converts the dot at the cell's coord to a dotted one
# depends on cell for `coord` and `nodes`.
func mark_cell_dotted(cell):
	# support multiple nodes per cell?
	var node = U.first(cell.nodes)
	if node == null:
		Log.warn("can't mark dotted, no node found!", cell)
		return

	if node.has_method("mark_dotted"):
		node.mark_dotted()
	else:
		Log.warn("some strange node loaded?")
		node.display_name = "Dotted"

	# update game state
	state.grid[cell.coord.y][cell.coord.x].erase("Dot")
	state.grid[cell.coord.y][cell.coord.x].append("Dotted")

# converts dotted back to dot (undo)
# depends on cell for `coord` and `nodes`.
func mark_cell_undotted(cell):
	# support multiple nodes per cell?
	var node = U.first(cell.nodes)
	if node == null:
		# undoing from goal doesn't require any undotting
		return

	if node.has_method("mark_undotted"):
		node.mark_undotted()
	else:
		Log.warn("some strange node loaded?")
		node.display_name = "Dot"

	# update game state
	state.grid[cell.coord.y][cell.coord.x].erase("Dotted")
	state.grid[cell.coord.y][cell.coord.x].append("Dot")

## move to dot ##############################################################

func move_to_dot(player, cell):
	# consider handling these in the same step (depending on the animation)
	move_player_to_cell(player, cell)
	mark_cell_dotted(cell)

## move to goal ##############################################################

func move_to_goal(player, cell):
	var move_finished = move_player_to_cell(player, cell)
	if all_dotted() and all_players_at_goal():
		state.win = true
		if move_finished:
			await move_finished
		win.emit()
	else:
		player.stuck = true

## undo last move ##############################################################

func undo_last_move(player):
	# supports the solver - undo moves state.win back to false
	state.win = false

	if len(player.move_history) == 0:
		Log.warn("Can't undo, no moves yet!")
		return
	# remove last move from move_history
	var last_pos = player.move_history.pop_front()
	var dest_cell = cell_at_coord(last_pos)

	# need to walk back the grid's Undo markers
	var prev_undo_coord = previous_undo_coord(player, dest_cell.coord, 0)
	if prev_undo_coord != null:
		if not "Undo" in state.grid[prev_undo_coord.y][prev_undo_coord.x]:
			state.grid[prev_undo_coord.y][prev_undo_coord.x].append("Undo")
	state.grid[dest_cell.coord.y][dest_cell.coord.x].erase("Undo")

	if last_pos == player.coord:
		if player.node.has_method("undo_to_same_coord"):
			player.node.undo_to_same_coord()
		return

	# move player node
	if player.node.has_method("undo_to_coord"):
		player.node.undo_to_coord(dest_cell.coord)
	else:
		player.node.position = dest_cell.coord * square_size

	# update game state
	state.grid[dest_cell.coord.y][dest_cell.coord.x].append("Player")
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
func move(move_dir):
	if move_dir == Vector2.ZERO:
		# don't do anything!
		return

	var moves_to_make = []
	for p in state.players:
		var cells = cells_in_direction(p.coord, move_dir)
		if len(cells) == 0:
			if p.stuck:
				moves_to_make.append(["stuck", null, p])
				if p.node.has_method("move_attempt_stuck"):
					p.node.move_attempt_stuck(move_dir)
			else:
				if p.node.has_method("move_attempt_away_from_edge"):
					p.node.move_attempt_away_from_edge(move_dir)
			continue

		cells = cells.filter(func(c): return c.objs != null)
		if len(cells) == 0:
			if p.stuck:
				moves_to_make.append(["stuck", null, p])
				if p.node.has_method("move_attempt_stuck"):
					p.node.move_attempt_stuck(move_dir)
			else:
				if p.node.has_method("move_attempt_only_nulls"):
					p.node.move_attempt_only_nulls(move_dir)
			continue

		# instead of markers, read undo based on only the player move history?
		var undo_cell_in_dir = U.first(cells.filter(func(c): return "Undo" in c.objs and c.coord in p.move_history))

		if undo_cell_in_dir != null:
			moves_to_make.append(["undo", undo_last_move, p, undo_cell_in_dir])
		else:
			for cell in cells:
				if p.stuck:
					# Log.warn("stuck, didn't see an undo in dir", move_dir, p.move_history)
					moves_to_make.append(["stuck", null, p])
					if p.node.has_method("move_attempt_stuck"):
						p.node.move_attempt_stuck(move_dir)
					break
				if "Player" in cell.objs:
					moves_to_make.append(["blocked_by_player", null, p])
					# moving toward player animation?
					break
				if "Dotted" in cell.objs:
					# moving toward dotted 'blocked' animation?
					continue
				if "Dot" in cell.objs:
					moves_to_make.append(["dot", move_to_dot, p, cell])
					break
				if "Goal" in cell.objs:
					moves_to_make.append(["goal", move_to_goal, p, cell])
					break
				Log.warn("unexpected/unhandled cell in direction", cell)

	var any_move = moves_to_make.any(func(m): return m[0] in ["dot", "goal"])
	if any_move:
		for p in state.players:
			p.move_history.push_front(p.coord)

		for m in moves_to_make:
			if m[0] in ["dot", "goal"]:
				m[1].call(m[2], m[3])

		# trigger HUD update
		player_moved.emit()
		return true # we moved!

	var any_undo = moves_to_make.any(func(m): return m[0] == "undo")
	if any_undo:
		for m in moves_to_make:
			# kind of wonky, could refactor to use a dict/struct
			undo_last_move(m[2])
		return

	# trigger HUD update
	move_rejected.emit()
