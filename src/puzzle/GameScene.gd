extends Node2D

## vars #####################################################################

@export_file var game_def_path: String
@export var puzzle_theme: PuzzleTheme
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

	# TODO add music controls and toasts
	# TODO stop music when pausing or navigating away
	SoundManager.stop_music(1.0)
	if puzzle_theme != null:
		var song = puzzle_theme.get_background_music()
		if song != null:
			SoundManager.play_music(song, 2.0)

func _exit_tree():
	SoundManager.stop_music(2.0)

func nav_to_world_map():
	# TODO better navigation (string-less, path-less)
	Navi.nav_to("res://src/menus/worldmap/WorldMapMenu.tscn")

## input ###################################################################

func _unhandled_input(event):
	if not Engine.is_editor_hint() and Trolls.is_pause(event):
		if not get_tree().paused:
			Navi.pause()
			get_viewport().set_input_as_handled()

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
	puzzle_node.player_undo.connect(update_hud)
	puzzle_node.move_attempted.connect(update_hud)
	puzzle_node.rebuilt_nodes.connect(update_hud)
	puzzle_node.move_blocked.connect(update_hud)

	setup_theme(puzzle_node)

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

func setup_theme(p_node):
	if not puzzle_theme:
		return
	p_node.player_scenes = puzzle_theme.get_player_scenes()
	p_node.dot_scenes = puzzle_theme.get_dot_scenes()
	p_node.goal_scenes = puzzle_theme.get_goal_scenes()

## win #####################################################################

var scene = preload("res://src/menus/PuzzleComplete.tscn")

func on_puzzle_win():
	Store.complete_puzzle_index(puzzle_set, puzzle_num)

	var game_complete = puzzle_num + 1 >= len(game_def.levels)

	var instance = scene.instantiate()
	instance.puzzle_set = puzzle_set
	instance.puzzle_num = puzzle_num

	var header
	var body
	if game_complete:
		header = "All %s Puzzles Complete!" % str(puzzle_num + 1)
		body = U.rand_of([
			"Your friends must think you're\npretty nerdy",
			"Be proud, for you are a nerd",
			"Congratulations, nerd!",
			"You're a real hop-dotter!",
			])

		Dino.notif("Puzzle Set complete!")
		Store.complete_puzzle_set(puzzle_set)
	else:
		header = "Puzzle %s Complete!" % str(puzzle_num + 1)
		body = U.rand_of(["....but how?", "Seriously impressive.", "Wowie zowie!"])

	puzzle_num += 1

	var opts = {header=header, body=body, pause=false,
		on_close=func():
		if game_complete:
			nav_to_world_map()
		else:
			if puzzle_node.has_method("animate_exit"):
				await puzzle_node.animate_exit()
			rebuild_puzzle()}

	if instance:
		opts["instance"] = instance

	Jumbotron.jumbo_notif(opts)
