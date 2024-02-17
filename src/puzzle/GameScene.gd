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
	rebuild_puzzle()


	hud = get_node_or_null("HUD")

	# TODO add music controls and toasts
	# TODO stop music when pausing or navigating away
	SoundManager.stop_music(1.0)
	var song = puzzle_theme.get_background_music()
	if song != null:
		SoundManager.play_music(song, 2.0)

func _exit_tree():
	var song = puzzle_theme.get_background_music()
	var songs = SoundManager.get_currently_playing_music()
	if len(songs) == 1:
		if songs[0] == song:
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
		# we "cross-fade" the in/out anims, then remove things later
		U.call_in(2.0, self, puzzle_node.queue_free)
		# remove_child.call_deferred(puzzle_node)
		# puzzle_node.queue_free.call_deferred()
		# # is this a race case? or is it impossible?
		# await puzzle_node.tree_exited

	# load current level
	puzzle_node = DotHopPuzzle.build_puzzle_node({
		# should we pass in the puzzle set here?
		game_def=game_def,
		puzzle_num=puzzle_num,
		puzzle_theme=puzzle_theme,
		})

	if puzzle_node == null:
		Log.warn("built puzzle_node is nil, returning to world map", puzzle_set)
		nav_to_world_map()
		return

	puzzle_node.win.connect(on_puzzle_win)
	puzzle_node.ready.connect(update_hud)

	puzzle_node.player_moved.connect(update_hud)
	puzzle_node.player_undo.connect(update_hud)
	puzzle_node.move_attempted.connect(update_hud)
	puzzle_node.rebuilt_nodes.connect(update_hud)
	puzzle_node.move_blocked.connect(update_hud)

	add_child.call_deferred(puzzle_node)
	puzzle_node.ready.connect(func(): Anim.puzzle_animate_intro_from_point(puzzle_node))

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
		if not puzzle_node.state.win: # skip updates after we've won (i.e. wait until next puzzle load)
			data["level_number"] = clamp(puzzle_num + 1, 1, total_levels)
			data["level_number_total"] = total_levels
		hud.update_state(data)

## load theme #####################################################################

func change_theme(theme):
	if puzzle_theme != theme:
		puzzle_theme = theme
		rebuild_puzzle()


## win #####################################################################

var PuzzleCompleteScene = preload("res://src/menus/PuzzleComplete.tscn")

func on_puzzle_win():
	Store.complete_puzzle_index(puzzle_set, puzzle_num)

	var puzzles_complete = puzzle_num + 1 >= len(game_def.levels)

	# TODO popup puzzle-set progress panel per puzzle-complete
	# maybe show number of moves, new dots collected, some solver stats
	# plus a hop-along the 'list of puzzle-icons board'

	if puzzles_complete:
		Dino.notif("Puzzle Set complete!")
		Store.complete_puzzle_set(puzzle_set)
		# some kind of fade or transition?
		nav_to_world_map()
	else:
		puzzle_num += 1
		Anim.puzzle_animate_outro_to_point(puzzle_node)
		rebuild_puzzle()

# func on_puzzle_win():
# 	Store.complete_puzzle_index(puzzle_set, puzzle_num)

# 	var puzzles_complete = puzzle_num + 1 >= len(game_def.levels)

# 	var instance = PuzzleCompleteScene.instantiate()
# 	instance.puzzle_set = puzzle_set
# 	instance.puzzle_num = puzzle_num

# 	var header
# 	var body
# 	if puzzles_complete:
# 		header = "All %s Puzzles Complete!" % str(puzzle_num + 1)
# 		body = U.rand_of([
# 			"Be proud! For you are a NERD",
# 			"Congratulations, nerd!",
# 			"You're a real hop-dotter!",
# 			])

# 		instance.ready.connect(func():
# 			var next_set = puzzle_set.get_next_puzzle_set()
# 			if next_set:
# 				instance.prizes.text = "[center]'%s' unlocked!" % next_set.get_display_name()
# 			else:
# 				instance.prizes.text = "[center]Dang, that was the last puzzle! You rock the house!")


# 		Dino.notif("Puzzle Set complete!")
# 		Store.complete_puzzle_set(puzzle_set)
# 	else:
# 		header = "Puzzle %s Complete!" % str(puzzle_num + 1)
# 		body = U.rand_of(["....but how?", "Seriously impressive.", "Wowie zowie!"])
# 		instance.ready.connect(func(): instance.prizes.set_visible(false))


# 	var opts = {header=header, body=body, pause=false,
# 		on_close=func():

# 		if puzzles_complete:
# 			# some kind of fade or transition?
# 			nav_to_world_map()
# 		else:
# 			puzzle_num += 1

# 		    # animate out
# 			var exit_t = 0.6
# 			# var exit_pos = puzzle_node.puzzle_rect().get_center()
# 			var puzz_rect = puzzle_node.puzzle_rect()
# 			var exit_poses = [
# 				puzz_rect.get_center(),
# 				# puzz_rect.position,
# 				# puzz_rect.end,
# 				]
# 			Log.pr(exit_poses)
# 			puzzle_node.state.players.map(func(p): Anim.slide_to_point(p.node,
# 				U.rand_of(exit_poses),
# 				exit_t))
# 			puzzle_node.all_cell_nodes().map(func(node): Anim.slide_to_point(node,
# 				U.rand_of(exit_poses),
# 				exit_t))
# 			# await get_tree().create_timer(exit_t/2).timeout

# 			rebuild_puzzle()}

# 	if instance:
# 		opts["instance"] = instance

# 	Jumbotron.jumbo_notif(opts)
