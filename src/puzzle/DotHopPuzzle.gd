@tool
extends Node2D
class_name DotHopPuzzle

## static ##########################################################################

static var fallback_puzzle_scene = "res://src/dotHop/puzzle/DotHopPuzzle.tscn"

# Builds and returns a "puzzle_scene" node, with a game_def and level_def set
# Accepts several input options, but only 'game_def' or 'game_def_path' are required.
#
# A raw puzzle or puzzle_num can be specified to load/pick a level for a particular game_def.
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
		Log.warn("No gamedef passed, cannot build_puzzle_node()", opts)
		return

	# parse/pick the puzzle to load
	var puzzle = opts.get("puzzle")
	# default to loading the first level
	var puzzle_num = opts.get("puzzle_num", 0)
	var _level_def

	if puzzle != null:
		_level_def = Puzz.parse_level_def(puzzle, opts.get("puzzle_message"))
	elif puzzle_num != null:
		_level_def = _game_def.levels[puzzle_num]
	else:
		pass

	if _level_def == null or _level_def.shape == null:
		Log.warn("Could not determine _level_def, cannot build_puzzle_node()")
		return

	# PackedScene, string, or use fallback
	var scene = opts.get("puzzle_scene")
	if scene is String:
		scene = load(scene)
	elif scene == null:
		scene = load(fallback_puzzle_scene)

	var node = scene.instantiate()
	node.game_def = _game_def
	node.level_def = _level_def
	return node

## vars ##############################################################

@export_file var game_def_path: String = "res://src/dotHop/dothop.txt" :
	set(gdp):
		game_def_path = gdp
		if gdp != "":
			game_def = Puzz.parse_game_def(gdp)
			level_def = game_def.levels[0]

@export var clear: bool = false:
	set(v):
		if v == true:
			clear_nodes()

var game_def
var level_def :
	set(ld):
		level_def = ld
		init_game_state()
@export var square_size = 64
var state

signal win

var obj_type = {
	"Dot": DHData.dotType.Dot,
	"Dotted": DHData.dotType.Dotted,
	"Goal": DHData.dotType.Goal,
	}

# NOTE these are overridden by each theme - essentially fallbacks for testing/debugging
var obj_scene = {
	"Player": preload("res://src/puzzle/Player.tscn"),
	"Dot": preload("res://src/puzzle/Dot.tscn"),
	"Dotted": preload("res://src/puzzle/Dot.tscn"),
	"Goal": preload("res://src/puzzle/Dot.tscn"),
	}

## enter_tree ##############################################################

func _init():
	add_to_group(DHData.puzzle_group, true)

## ready ##############################################################

func _ready():
	if level_def == null:
		Log.pr("no level_def, trying backups!", name)
		if game_def_path != "":
			game_def = Puzz.parse_game_def(game_def_path)
			level_def = game_def.levels[0]
			init_game_state()
		else:
			Log.err("no game_def_path!!")
	else:
		init_game_state()

## input ##############################################################

func _unhandled_input(event):
	if state != null and state.win:
		Log.pr("Blocking input events b/c we're in a win state")
		return

	if Trolls.is_move(event):
		if state == null:
			Log.warn("No state, ignoring move input")
			return
		check_move_input()
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
		Log.prn(state.grid)

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

## check_move_input ##############################################################

var block_move
var last_move

func check_move_input():
	var move_vec = Trolls.grid_move_vector()

	if move_vec != last_move:
		# allow moving in a new direction
		block_move = false

	if move_vec != Vector2.ZERO and not block_move:
		last_move = move_vec
		move(move_vec)
		restart_block_move_timer()

var block_move_timer
func restart_block_move_timer(t=0.2):
	block_move = true
	if block_move_timer != null:
		block_move_timer.kill()
	block_move_timer = create_tween()
	block_move_timer.tween_callback(func():
		block_move = false
		check_move_input()).set_delay(t)

## state/grid ##############################################################

# sets up the state grid and some initial data based on the assigned level_def
func init_game_state():
	if len(level_def.shape) == 0:
		Log.warn("init_game_state() called with out level_def.shape", level_def)
		return

	var grid = []
	var players = []
	for y in len(level_def.shape):
		var row = level_def.shape[y]
		var r = []
		for x in len(row):
			var cell = level_def.shape[y][x]
			var objs = get_cell_objs(cell)
			r.append(objs)
		grid.append(r)

	state = {players=players, grid=grid, grid_xs=len(grid[0]), grid_ys=len(grid), win=false, cell_nodes={}}

	rebuild_nodes()

func get_cell_objs(cell):
	var objs = Puzz.get_cell_objects(game_def, cell)
	if objs != null and len(objs) > 0:
		objs = objs.map(func(n):
			if n in ["PlayerA", "PlayerB"]:
				return "Player"
			else:
				return n)
	return objs

## setup level ##############################################################

func init_player(coord, node) -> Dictionary:
	return {coord=coord, stuck=false, move_history=[], node=node}

func clear_nodes():
	for ch in get_children():
		if ch.is_in_group("generated"):
			ch.free()

var cam_anchor
var cam_anchor_scene = preload("res://addons/camera/CamAnchor.tscn")
func ensure_camera_anchor():
	if len(state.grid) == 0:
		return
	if cam_anchor == null:
		cam_anchor = cam_anchor_scene.instantiate()
		cam_anchor.position = Vector2(len(state.grid[0]), len(state.grid)) * square_size / 2
		add_child(cam_anchor)

	Cam.request_camera({
		anchor=cam_anchor,
		# could use dynamic zoom based on level size
		zoom_level=2.5,
		# zoom_offset=1000.0,
		mode=Cam.mode.ANCHOR})

# Adds nodes for the object_names in each cell of the grid.
# Tracks nodes (except for players) in a state.cell_nodes dict.
# Tracks players in state.players list.
func rebuild_nodes():
	clear_nodes()

	if not Engine.is_editor_hint():
		ensure_camera_anchor()

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
				else:
					if not coord in state.cell_nodes:
						state.cell_nodes[coord] = []
					state.cell_nodes[coord].append(node)

	# TODO trigger a HUD update

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
	add_child(node)
	node.set_owner(self)
	return node

func node_for_object_name(obj_name):
	var scene = obj_scene.get(obj_name)
	if not scene:
		Log.err("No scene found for object name", obj_name)
		return
	var node = scene.instantiate()
	node.display_name = obj_name
	var t = obj_type.get(obj_name)
	if t != null and "type" in node:
		node.type = t
	elif obj_name not in ["Player"]:
		Log.warn("no type for object?", obj_name)
	return node

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
	var last_cursor
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
			if only_undotted and obj_name in ["Dot", "Goal"]:
				return true
			elif not only_undotted and obj_name in ["Dot", "Dotted", "Goal"]:
				return true
		return false))


func all_players_at_goal() -> bool:
	return all_cells().filter(func(c):
		if c != null and "Goal" in c:
			return true
		).all(func(c): return "Player" in c)

func all_cell_nodes() -> Array[Variant]:
	return state.cell_nodes.values().reduce(func(agg, nodes):
		agg.append_array(nodes)
		return agg)

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
	if player.node.has_method("move_to_coord"):
		player.node.move_to_coord(cell.coord)
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
	move_player_to_cell(player, cell)
	if all_dotted() and all_players_at_goal():
		state.win = true
		win.emit()
	else:
		player.stuck = true

## undo last move ##############################################################

func undo_last_move(player):
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
					Log.warn("stuck, didn't see an undo in dir", p.stuck, move_dir, p.move_history)
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

		# TODO Update data/HUD
		return

	var any_undo = moves_to_make.any(func(m): return m[0] == "undo")
	if any_undo:
		for m in moves_to_make:
			# kind of wonky, could refactor to use a dict/struct
			undo_last_move(m[2])

	# TODO Update data/HUD