extends Node2D
class_name DotHopGame

## vars #####################################################################

@export var world: PuzzleWorld
@export var puzzle_num: int = 0

var puzzle_node: DotHopPuzzle
var puzzle_theme_data: PuzzleThemeData

var already_complete: bool = false

var hud: HUD
var dhcam: DotHopCam

## ready #####################################################################

func _ready() -> void:
	if world == null:
		Log.warn("No puzzle set, grabbing fallback from store")
		world = Store.get_worlds()[0]

	if world != null:
		puzzle_theme_data = world.get_theme_data()
	else:
		Log.warn("no world, cannot start GameScene")

	rebuild_puzzle()

	hud = get_node_or_null("HUD")

	if not Engine.is_editor_hint() and is_inside_tree():
		dhcam = DotHopCam.ensure_camera(self)
		puzzle_node.rebuilt_nodes.connect(func() -> void:
			dhcam.center_on_rect(puzzle_node.puzzle_rect()),
			CONNECT_DEFERRED)

	# TODO add music controls and toasts
	SoundManager.stop_music(1.0)
	var songs: Array[AudioStream] = puzzle_theme_data.get_music_tracks()
	if len(songs) > 0:
		SoundManager.play_music(songs[0], 2.0)

func _exit_tree() -> void:
	var playing_songs: Array = SoundManager.get_currently_playing_music()
	if len(playing_songs) == 1:
		# if only one song is playing, stop it
		# otherwise, assume the cross-fade is working
		SoundManager.stop_music(2.0)

func nav_to_world_map() -> void:
	# TODO navigation via enum (string-less, path-less)
	Navi.nav_to("res://src/menus/worldmap/WorldMapMenu.tscn")

func nav_to_credits() -> void:
	Navi.nav_to("res://src/menus/Credits.tscn")

## input ###################################################################

func _unhandled_input(event: InputEvent) -> void:
	if not Engine.is_editor_hint() and Trolls.is_pause(event):
		DotHop.maybe_pause()

## rebuild puzzle #####################################################################

func rebuild_puzzle() -> void:
	if puzzle_node != null:
		var outro_complete: Signal = Anim.puzzle_animate_outro_to_point(puzzle_node)
		await outro_complete
		puzzle_node.queue_free()

	# load current puzzle
	puzzle_node = DotHopPuzzle.build_puzzle_node({
		world=world, puzzle_def=world.get_puzzles()[puzzle_num],
		theme_data=puzzle_theme_data
		})

	if puzzle_node == null:
		Log.error("built puzzle_node is nil! aborting rebuild_puzzle")
		return

	puzzle_node.win.connect(on_puzzle_win, CONNECT_ONE_SHOT)

	connect_animations()
	connect_hud_updates()
	connect_sounds()

	add_child.call_deferred(puzzle_node)

## connect_hud #####################################################################

func connect_animations() -> void:
	puzzle_node.rebuilt_nodes.connect(func() -> void:
		Anim.puzzle_animate_intro_from_point(puzzle_node))
	puzzle_node.ready.connect(func() -> void:
		Anim.puzzle_animate_intro_from_point(puzzle_node))

func connect_hud_updates() -> void:
	if not hud:
		return

	puzzle_node.ready.connect(update_hud)

	puzzle_node.player_moved.connect(func() -> void:
		update_hud()
		hud.restart_fade_in_controls_tween())
	puzzle_node.player_undo.connect(func() -> void:
		update_hud()
		hud.animate_undo()
		hud.restart_fade_in_controls_tween())
	puzzle_node.move_rejected.connect(func() -> void:
		update_hud()
		hud.show_controls(true)
		DotHop.notif("Move Rejected", {id="move_reaction"}))
	puzzle_node.move_input_blocked.connect(func() -> void:
		update_hud()
		DotHop.notif("Move Blocked", {id="move_reaction"}))
	puzzle_node.rebuilt_nodes.connect(func() -> void:
		update_hud()
		DotHop.notif("Puzzle Rebuilt", {id="puzzle_rebuilt"}))

	puzzle_node.ready.connect(func() -> void:
		hud.reset_pressed.connect(puzzle_node.reset_pressed)
		hud.undo_pressed.connect(puzzle_node.undo_pressed)
		hud.shuffle_pressed.connect(puzzle_node.shuffle_pressed))

## connect_sounds #####################################################################

# TODO consider move to DotHopSounds or something like it
# i think these sounds need to know what the theme is?
# they're at least 'world' dependent
func connect_sounds() -> void:
	puzzle_node.win.connect(sound_on_win)
	puzzle_node.player_moved.connect(sound_on_player_moved)
	puzzle_node.player_undo.connect(sound_on_player_undo)
	puzzle_node.move_rejected.connect(sound_on_move_rejected)
	puzzle_node.move_input_blocked.connect(sound_on_move_input_blocked)
	puzzle_node.rebuilt_nodes.connect(sound_on_rebuilt_nodes)

func sound_on_win() -> void:
	Sounds.play(Sounds.S.complete)

func sound_on_player_moved() -> void:
	var total_dots: float = float(puzzle_node.state.dot_count() + 1)
	var dotted: float = total_dots - float(puzzle_node.state.dot_count(true)) - 1
	# ensure some minimum
	dotted = clamp(dotted, total_dots/4, total_dots)
	if puzzle_node.state.win:
		dotted += 1
	Sounds.play(Sounds.S.dot_collected, {scale_range=total_dots, scale_note=dotted, interrupt=true})

func sound_on_player_undo() -> void:
	Sounds.play(Sounds.S.minimize)

func sound_on_move_rejected() -> void:
	Sounds.play(Sounds.S.showjumbotron)

func sound_on_move_input_blocked() -> void:
	pass

func sound_on_rebuilt_nodes() -> void:
	Sounds.play(Sounds.S.maximize)

## update hud #####################################################################

func update_hud() -> void:
	if hud and puzzle_node:
		var rem: int = len(world.get_puzzles().filter(func(p: PuzzleDef) -> bool: return not p.is_completed))
		var data: Dictionary = {
			puzzle_def=puzzle_node.puzzle_def,
			puzzles_remaining=rem,
			dots_total=puzzle_node.state.dot_count(),
			dots_remaining=puzzle_node.state.dot_count(true),
			}
		hud.update_state(data)

## load theme #####################################################################

func change_theme(theme: PuzzleTheme) -> void:
	var td := theme.get_theme_data()
	if puzzle_theme_data != td:
		puzzle_theme_data = td
		rebuild_puzzle()

## win #####################################################################

var PuzzleCompleteScene: PackedScene = preload("res://src/menus/jumbotrons/PuzzleComplete.tscn")
var WorldUnlockedScene: PackedScene = preload("res://src/menus/jumbotrons/WorldUnlocked.tscn")
var ProgressPanelScene: PackedScene = preload("res://src/ui/components/PuzzleProgressPanel.tscn")

func on_puzzle_win() -> void:
	Log.info("Puzzle complete!", world.get_display_name(), "-", puzzle_num)
	Store.complete_puzzle_index(world, puzzle_num)

	# refresh world data
	world = Store.find_world(world)
	var completed_world: bool = world.get_puzzles().all(func(pd: PuzzleDef) -> bool: return pd.is_completed)

	var worlds: Array[PuzzleWorld] = Store.get_worlds()
	var stats: Dictionary = DHData.calc_stats(worlds)
	var opts: Dictionary = {stats=stats}
	if completed_world:
		Store.complete_world(world)
		opts["complete_world"] = world
	# fires achievement update (dot counts, completed puzzle set)
	update_achievements(opts)

	# fetch again after completing puzzle sets
	worlds = Store.get_worlds()
	var to_unlock: Array = []
	for w: PuzzleWorld in worlds:
		if not w.is_unlocked() and w.get_puzzles_to_unlock() <= stats.puzzles_completed:
			to_unlock.append(w)

	for ps: PuzzleWorld in to_unlock:
		Store.unlock_world(ps)
		await show_unlock_jumbo(ps)

	if already_complete:
		var end_of_world: bool = puzzle_num + 1 >= len(world.get_puzzles())
		if end_of_world:
			DotHop.notif("All puzzles complete!")
			await show_world_complete_jumbo()
			nav_to_world_map()
		else:
			var next_puzzle_num: int = puzzle_num + 1
			show_progress_toast(next_puzzle_num)
			puzzle_num = next_puzzle_num
			rebuild_puzzle()
	elif stats.puzzles_completed == stats.total_puzzles:
		DotHop.notif("All puzzles complete!")
		await show_no_more_puzzles_jumbo()
		nav_to_credits()
	elif completed_world:
		DotHop.notif("Completed puzzle set!")
		await show_world_complete_jumbo()
		nav_to_world_map()
	else:
		var puzzles: Array[PuzzleDef] = world.get_puzzles()
		var next_puzzle_num: int
		for i: int in range(puzzle_num, len(puzzles) + puzzle_num):
			i = i % len(puzzles)
			var puzz: PuzzleDef = puzzles[i]
			if not puzz.is_completed:
				next_puzzle_num = i
				break

		show_progress_toast(next_puzzle_num)
		puzzle_num = next_puzzle_num
		rebuild_puzzle()

## achievements ################################################################333

# TODO omg move to achievements class or anywhere else
func update_achievements(opts: Dictionary = {}) -> void:
	var complete_world: PuzzleWorld = opts.get("complete_world")

	if complete_world:
		match (complete_world.get_entity_id()):
			PuzzleWorldIDs.THEMDOTS: GodotSteam.set_them_dots_complete()
			PuzzleWorldIDs.SPRINGINYOURHOP: GodotSteam.set_spring_in_your_hop_complete()
			PuzzleWorldIDs.THATSJUSTBEACHY: GodotSteam.set_thats_just_beachy_complete()
			PuzzleWorldIDs.LEAFMEALONE: GodotSteam.set_leaf_me_alone_complete()
			PuzzleWorldIDs.SNOWWAY: GodotSteam.set_snow_way_complete()
			PuzzleWorldIDs.GETOUTERHERE:
				GodotSteam.set_get_outer_here_complete()

	var worlds: Array[PuzzleWorld] = Store.get_worlds()
	var all_complete: bool = worlds.all(func(ps: PuzzleWorld) -> bool: return ps.is_completed())
	if all_complete:
		GodotSteam.set_all_puzzles_complete()

	var stats: Dictionary = opts.get("stats")
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

func show_progress_toast(next_puzzle_num: int) -> void:
	var panel: PuzzleProgressPanel = ProgressPanelScene.instantiate()
	panel.icon_size = 48.0
	panel.grid_columns = 6
	panel.disable_resize_animation()
	var lock_puzz_num: int = puzzle_num
	panel.ready.connect(func() -> void:
		panel.render({
			world=world,
			start_puzzle_num=lock_puzz_num,
			end_puzzle_num=next_puzzle_num
			}))
	panel.rendered.connect(func() -> void:
		# wait for panel to finish resizing
		Anim.toast(panel, {wait_frame=true, in_t=0.7, out_t=0.7, delay=1.0, margin=48}))
	hud.add_child.call_deferred(panel)


## all puzzles jumbo #####################################################################

func show_world_complete_jumbo() -> Signal:
	var header: String = "[color=crimson]%s[/color] Complete!" % world.get_display_name()
	# var body = U.rand_of(["....but how?", "Seriously impressive.", "Wowie zowie!"])
	var body: String = U.rand_of([
		"Be proud! For you are a NERD",
		"Congratulations, nerd!",
		"You're a real hop-dotter!",
		])

	var instance: PuzzleComplete = PuzzleCompleteScene.instantiate()
	instance.world = world
	instance.start_puzzle_num = puzzle_num - 1
	instance.end_puzzle_num = puzzle_num

	var opts: Dictionary = {header=header, body=body, pause=false, instance=instance}

	return Jumbotron.jumbo_notif(opts)

## unlock jumbo #####################################################################

func show_unlock_jumbo(w: PuzzleWorld) -> Signal:
	var instance: PuzzleUnlocked = WorldUnlockedScene.instantiate()
	instance.world = w
	return Jumbotron.jumbo_notif({pause=false, instance=instance})

## no more puzzles jumbo #####################################################################

func show_no_more_puzzles_jumbo() -> Signal:
	var instance: Node = WorldUnlockedScene.instantiate()
	return Jumbotron.jumbo_notif({pause=false, instance=instance})
