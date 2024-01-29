extends Node2D

## vars #####################################################################

@export_file var game_def_path: String
@export var puzzle_theme: DotHopTheme
@export var puzzle_set: PuzzleSet

var game_def
var puzzle_node
var puzzle_scene
@export var puzzle_num = 0

var hud

## ready #####################################################################

func _ready():
	if puzzle_set == null:
		puzzle_set = Pandora.get_entity(PuzzleSetIDs.ONE)

	if puzzle_set != null:
		game_def_path = puzzle_set.get_puzzle_script_path()
		puzzle_theme = puzzle_set.get_theme()

	if game_def_path == null:
		Log.warn("No game_def_path found!!")
		return

	game_def = Puzz.parse_game_def(game_def_path)
	load_theme()
	rebuild_puzzle()

	hud = get_node_or_null("HUD")

func nav_to_world_map():
	# TODO better navigation (string-less, path-less)
	Navi.nav_to("res://src/menus/worldmap/WorldMapMenu.tscn")


## rebuild puzzle #####################################################################

func rebuild_puzzle():
	if puzzle_node != null:
		remove_child.call_deferred(puzzle_node)
		puzzle_node.queue_free()
		# is this a race case? or is it impossible?
		await puzzle_node.tree_exited

	# load current level
	puzzle_node = DotHopPuzzle.build_puzzle_node({
		game_def=game_def,
		puzzle_num=puzzle_num,
		puzzle_scene=puzzle_scene
		})

	if puzzle_node == null:
		Log.warn("built puzzle_node is nil, returning to world map", puzzle_set)
		nav_to_world_map()
		return

	puzzle_node.win.connect(on_puzzle_win)
	puzzle_node.ready.connect(on_puzzle_ready)

	puzzle_node.player_moved.connect(update_hud)
	puzzle_node.move_attempted.connect(update_hud)
	puzzle_node.rebuilt_nodes.connect(update_hud)
	puzzle_node.move_blocked.connect(update_hud)

	add_child.call_deferred(puzzle_node)

func on_puzzle_ready():
	update_hud()

func update_hud():
	if hud and puzzle_node:
		# TODO trace and consider/model the data sources here
		# TODO unit test for getting this data at various times during gameplay
		var ld = puzzle_node.level_def
		var message
		if ld != null and "message" in ld and ld.message != "":
			message = ld.message
		var data = {
			dots_total=puzzle_node.dot_count(),
			dots_remaining=puzzle_node.dot_count(true),
			}
		if message != null:
			data["level_message"] = message
		var total_levels = len(game_def.levels)
		data["level_number"] = clamp(puzzle_num + 1, 1, total_levels)
		data["level_number_total"] = total_levels
		hud.update_state(data)

## load theme #####################################################################

func load_theme():
	puzzle_scene = puzzle_theme.get_puzzle_scene()

func change_theme(theme):
	if puzzle_theme != theme:
		puzzle_theme = theme
		load_theme()
		rebuild_puzzle()

## win #####################################################################

func on_puzzle_win():
	# juicy win scene with button to advance
	# metrics like number of moves, time
	# leaderboard via that wolf thing?

	puzzle_num += 1

	var game_complete = puzzle_num >= len(game_def.levels)

	var header
	var body
	if game_complete:
		header = "All %s Puzzles Complete!" % puzzle_num
		body = "Your friends must think you're\npretty nerdy"
	else:
		header = "Puzzle %s Complete!" % puzzle_num
		body = "....but how?"

	Jumbotron.jumbo_notif({
		header=header, body=body, pause=false,
		on_close=func():
		if game_complete:
			# TODO move to nice toast/notif components, maybe fire from the store?
			Dino.notif("Puzzle Set complete!")

			# function call, or emit event ?
			Store.complete_puzzle_set(puzzle_set)
			nav_to_world_map()
		else:
			if puzzle_node.has_method("animate_exit"):
				await puzzle_node.animate_exit()
			Dino.notif("Building next level!")
			rebuild_puzzle()})
