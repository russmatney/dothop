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
		puzzle_set = Store.get_puzzle_sets()[0]

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
	SoundManager.stop_music(1.0)
	var songs = puzzle_theme.get_music_tracks()
	if len(songs) > 0:
		SoundManager.play_music(songs[0], 2.0)

func _exit_tree():
	var playing_songs = SoundManager.get_currently_playing_music()
	if len(playing_songs) == 1:
		# if only one song is playing, stop it
		# otherwise, assume the cross-fade is working
		SoundManager.stop_music(2.0)

func nav_to_world_map():
	# TODO navigation via enum (string-less, path-less)
	Navi.nav_to("res://src/menus/worldmap/WorldMapMenu.tscn")

func nav_to_credits():
	Navi.nav_to("res://src/menus/Credits.tscn")

## input ###################################################################

func _unhandled_input(event):
	if not Engine.is_editor_hint() and Trolls.is_pause(event):
		if not get_tree().paused:
			Navi.pause()
			get_viewport().set_input_as_handled()

## rebuild puzzle #####################################################################

func rebuild_puzzle():
	if puzzle_node != null:
		var outro_complete = Anim.puzzle_animate_outro_to_point(puzzle_node)
		await outro_complete
		puzzle_node.queue_free()

	# load current puzzle
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

	puzzle_node.player_moved.connect(func():
		update_hud()
		hud.restart_fade_in_controls_tween())
	puzzle_node.player_undo.connect(func():
		update_hud()
		hud.animate_undo()
		hud.restart_fade_in_controls_tween())
	puzzle_node.move_rejected.connect(func():
		update_hud()
		hud.show_controls(true))
	puzzle_node.move_blocked.connect(update_hud)
	puzzle_node.rebuilt_nodes.connect(func():
		update_hud()
		Anim.puzzle_animate_intro_from_point(puzzle_node)
		)

	add_child.call_deferred(puzzle_node)
	puzzle_node.ready.connect(func(): Anim.puzzle_animate_intro_from_point(puzzle_node))

## update hud #####################################################################

func update_hud():
	if hud and puzzle_node:
		var data = {
			puzzle_def=puzzle_node.puzzle_def,
			puzzle_number_total=len(game_def.puzzles),
			dots_total=puzzle_node.dot_count(),
			dots_remaining=puzzle_node.dot_count(true),
			}
		hud.update_state(data)

## load theme #####################################################################

func change_theme(theme):
	if puzzle_theme != theme:
		puzzle_theme = theme
		rebuild_puzzle()

## win #####################################################################

var PuzzleCompleteScene = preload("res://src/menus/jumbotrons/PuzzleComplete.tscn")
var PuzzleSetUnlockedScene = preload("res://src/menus/jumbotrons/PuzzleSetUnlocked.tscn")
var ProgressPanelScene = preload("res://src/ui/components/PuzzleProgressPanel.tscn")

func on_puzzle_win():
	Store.complete_puzzle_index(puzzle_set, puzzle_num)

	var stats = calc_stats()

	if stats.dots_hopped > 10:
		GodotSteam.set_ten_dots()
	if stats.dots_hopped > 50:
		GodotSteam.set_fifty_dots()
	if stats.dots_hopped > 100:
		GodotSteam.set_one_hundred_dots()
	if stats.dots_hopped > 500:
		GodotSteam.set_five_hundred_dots()
	if stats.dots_hopped > 1 and stats.dots_hopped == stats.total_dots:
		GodotSteam.set_all_the_dots()

	var puzz_sets = Store.get_puzzle_sets()
	var to_unlock = []
	for puzz_set in puzz_sets:
		if not puzz_set.is_unlocked() and puzz_set.get_puzzles_to_unlock() <= stats.puzzles_complete:
			to_unlock.append(puzz_set)

	for ps in to_unlock:
		Store.unlock_puzzle_set(ps)

	var puzzles_complete = puzzle_num + 1 >= len(game_def.puzzles)

	if puzzles_complete:
		Dino.notif("Puzzle Set complete!")
		Store.complete_puzzle_set(puzzle_set)

		await show_all_puzzles_jumbo()

		for ps in to_unlock:
			await show_unlock_jumbo(ps)

		if stats.puzzles_complete == stats.total_puzzles:
			await show_no_more_puzzles_jumbo()
			nav_to_credits()
		else:
			nav_to_world_map()
	else:
		if puzzle_node.puzzle_def.meta.get("show_progress"):
			await show_progress_jumbo()

			for ps in to_unlock:
				await show_unlock_jumbo(ps)
		else:
			for ps in to_unlock:
				await show_unlock_jumbo(ps)

			var panel = ProgressPanelScene.instantiate()
			panel.icon_size = 48.0
			panel.grid_columns = 6
			panel.disable_resize_animation()
			var lock_puzz_num = puzzle_num
			panel.ready.connect(func():
				panel.render({
					puzzle_set=puzzle_set,
					start_puzzle_num=lock_puzz_num,
					end_puzzle_num=lock_puzz_num + 1,
					}))
			panel.rendered.connect(func():
				# wait for panel to finish resizing
				Anim.toast(panel, {wait_frame=true, in_t=0.7, out_t=0.7, delay=1.0, margin=48}))
			hud.add_child.call_deferred(panel)

		puzzle_num += 1
		rebuild_puzzle()

# TODO DRY up count against the main menu stat calc
func calc_stats():
	var total_puzzles = 0
	var puzzles_complete = 0
	var total_dots = 0
	var _dots_hopped = 0

	for ps in Store.get_puzzle_sets():
		for p in ps.get_puzzles():
			total_dots += p.dot_count()
			total_puzzles += 1
			if p.is_completed:
				puzzles_complete += 1
				_dots_hopped += p.dot_count()

	return {
		total_dots=total_dots, dots_hopped=_dots_hopped,
		total_puzzles=total_puzzles, puzzles_complete=puzzles_complete,
		}

## progress jumbo #####################################################################

var last_puzzle_num = 0

func show_progress_jumbo():
	var ct = puzzle_num + 1 - last_puzzle_num
	var header = "%s Puzzles Complete!" % str(ct)
	var body = U.rand_of(["....but how?", "Seriously impressive.", "Wowie zowie!"])
	var instance = PuzzleCompleteScene.instantiate()
	instance.puzzle_set = puzzle_set
	instance.start_puzzle_num = last_puzzle_num
	last_puzzle_num = puzzle_num + 1
	instance.end_puzzle_num = puzzle_num + 1

	var opts = {header=header, body=body, pause=false, instance=instance}
	return Jumbotron.jumbo_notif(opts)

## all puzzles jumbo #####################################################################

func show_all_puzzles_jumbo():
	var header = "All %s Puzzles Complete!" % str(puzzle_num + 1)
	var body = U.rand_of([
		"Be proud! For you are a NERD",
		"Congratulations, nerd!",
		"You're a real hop-dotter!",
		])

	var instance = PuzzleCompleteScene.instantiate()
	instance.puzzle_set = puzzle_set
	instance.start_puzzle_num = last_puzzle_num
	last_puzzle_num = 0
	instance.end_puzzle_num = puzzle_num

	var opts = {header=header, body=body, pause=false, instance=instance}

	return Jumbotron.jumbo_notif(opts)

## unlock jumbo #####################################################################

func show_unlock_jumbo(puzz_set):
	var instance = PuzzleSetUnlockedScene.instantiate()
	instance.puzzle_set = puzz_set
	return Jumbotron.jumbo_notif({pause=false, instance=instance})

## no more puzzles jumbo #####################################################################

func show_no_more_puzzles_jumbo():
	var instance = PuzzleSetUnlockedScene.instantiate()
	return Jumbotron.jumbo_notif({pause=false, instance=instance})
