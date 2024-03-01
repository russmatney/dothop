extends Node2D

## vars #####################################################################

@export_file var game_def_path: String
@export var puzzle_theme: PuzzleTheme
@export var puzzle_set: PuzzleSet

var game_def
var puzzle_node
var puzzle_scene
@export var puzzle_num = 0

var already_complete = false

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
		Anim.puzzle_animate_intro_from_point(puzzle_node))

	add_child.call_deferred(puzzle_node)
	puzzle_node.ready.connect(func(): Anim.puzzle_animate_intro_from_point(puzzle_node))

## update hud #####################################################################

func update_hud():
	if hud and puzzle_node:
		var rem = len(puzzle_set.get_puzzles().filter(func(p): return not p.is_completed))
		var data = {
			puzzle_def=puzzle_node.puzzle_def,
			puzzles_remaining=rem,
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

	# refresh puzzle_set data
	puzzle_set = Store.find_puzzle_set(puzzle_set)
	var completed_puzzle_set = puzzle_set.get_puzzles().all(func(ps): return ps.is_completed)

	var puzz_sets = Store.get_puzzle_sets()
	var stats = DHData.calc_stats(puzz_sets)
	var opts = {stats=stats}
	if completed_puzzle_set:
		Store.complete_puzzle_set(puzzle_set)
		opts["complete_puzzle_set"] = puzzle_set
	# fires achievement update (dot counts, completed puzzle set)
	update_achievements(opts)

	# fetch again after completing puzzle sets
	puzz_sets = Store.get_puzzle_sets()
	var to_unlock = []
	for puzz_set in puzz_sets:
		if not puzz_set.is_unlocked() and puzz_set.get_puzzles_to_unlock() <= stats.puzzles_completed:
			to_unlock.append(puzz_set)

	for ps in to_unlock:
		Store.unlock_puzzle_set(ps)
		await show_unlock_jumbo(ps)

	if already_complete:
		var end_of_puzzle_set = puzzle_num + 1 >= len(game_def.puzzles)
		if end_of_puzzle_set:
			Dino.notif("All puzzles complete!")
			await show_puzzle_set_complete_jumbo()
			nav_to_world_map()
		else:
			var next_puzzle_num = puzzle_num + 1
			show_progress_toast(next_puzzle_num)
			puzzle_num = next_puzzle_num
			rebuild_puzzle()
	elif stats.puzzles_completed == stats.total_puzzles:
		Dino.notif("All puzzles complete!")
		await show_no_more_puzzles_jumbo()
		nav_to_credits()
	elif completed_puzzle_set:
		Dino.notif("Completed puzzle set!")
		await show_puzzle_set_complete_jumbo()
		nav_to_world_map()
	else:
		var puzzles = puzzle_set.get_puzzles()
		var next_puzzle_num
		for i in range(puzzle_num, len(puzzles) + puzzle_num):
			i = i % len(puzzles)
			var puzz = puzzles[i]
			if not puzz.is_completed:
				next_puzzle_num = i
				break

		show_progress_toast(next_puzzle_num)
		puzzle_num = next_puzzle_num
		rebuild_puzzle()

## achievements ################################################################333

func update_achievements(opts={}):
	var complete_puzzle_set = opts.get("complete_puzzle_set")

	if complete_puzzle_set:
		match (complete_puzzle_set.get_entity_id()):
			PuzzleSetIDs.THEMDOTS: GodotSteam.set_them_dots_complete()
			PuzzleSetIDs.SPRINGINYOURHOP: GodotSteam.set_spring_in_your_hop_complete()
			PuzzleSetIDs.THATSJUSTBEACHY: GodotSteam.set_thats_just_beachy_complete()
			PuzzleSetIDs.LEAFMEALONE: GodotSteam.set_leaf_me_alone_complete()
			PuzzleSetIDs.SNOWWAY: GodotSteam.set_snow_way_complete()
			PuzzleSetIDs.GETOUTERHERE:
				GodotSteam.set_get_outer_here_complete()

	var puzzle_sets = Store.get_puzzle_sets()
	var all_complete = puzzle_sets.all(func(ps): return ps.is_completed())
	if all_complete:
		GodotSteam.set_all_puzzles_complete()

	var stats = opts.get("stats")
	if not stats:
		return

	if stats.dots_hopped > 10:
		GodotSteam.set_ten_dots()
	if stats.dots_hopped > 50:
		GodotSteam.set_fifty_dots()
	if stats.dots_hopped > 100:
		GodotSteam.set_one_hundred_dots()
	if stats.dots_hopped > 200:
		GodotSteam.set_two_hundred_dots()
	if stats.dots_hopped > 300:
		GodotSteam.set_three_hundred_dots()
	if stats.dots_hopped > 400:
		GodotSteam.set_four_hundred_dots()
	if stats.dots_hopped > 500:
		GodotSteam.set_five_hundred_dots()
	if stats.dots_hopped > 600:
		GodotSteam.set_six_hundred_dots()
	if stats.dots_hopped > 700:
		GodotSteam.set_seven_hundred_dots()
	if stats.dots_hopped > 800:
		GodotSteam.set_eight_hundred_dots()
	if stats.dots_hopped > 900:
		GodotSteam.set_nine_hundred_dots()
	if stats.dots_hopped > 1000:
		GodotSteam.set_one_thousand_dots()
	if stats.dots_hopped > 1 and stats.dots_hopped == stats.total_dots:
		GodotSteam.set_all_the_dots()

## progress toast #####################################################################

func show_progress_toast(next_puzzle_num):
	var panel = ProgressPanelScene.instantiate()
	panel.icon_size = 48.0
	panel.grid_columns = 6
	panel.disable_resize_animation()
	var lock_puzz_num = puzzle_num
	panel.ready.connect(func():
		panel.render({
			puzzle_set=puzzle_set,
			start_puzzle_num=lock_puzz_num,
			end_puzzle_num=next_puzzle_num
			}))
	panel.rendered.connect(func():
		# wait for panel to finish resizing
		Anim.toast(panel, {wait_frame=true, in_t=0.7, out_t=0.7, delay=1.0, margin=48}))
	hud.add_child.call_deferred(panel)


## all puzzles jumbo #####################################################################

func show_puzzle_set_complete_jumbo():
	var header = "[color=crimson]%s[/color] Complete!" % puzzle_set.get_display_name()
	# var body = U.rand_of(["....but how?", "Seriously impressive.", "Wowie zowie!"])
	var body = U.rand_of([
		"Be proud! For you are a NERD",
		"Congratulations, nerd!",
		"You're a real hop-dotter!",
		])

	var instance = PuzzleCompleteScene.instantiate()
	instance.puzzle_set = puzzle_set
	instance.start_puzzle_num = puzzle_num - 1
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
