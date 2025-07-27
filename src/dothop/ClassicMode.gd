extends Node
class_name ClassicMode

## vars ###################################################################

@export var puzzle_num: int = 0

var already_complete: bool = false

## ready #####################################################################

func _ready() -> void:
	Events.puzzle_node.win.connect(func(evt: Events.Evt) -> void:
		on_puzzle_win(evt.puzzle_node))

## win #####################################################################

var PuzzleCompleteScene: PackedScene = preload("res://src/menus/jumbotrons/PuzzleComplete.tscn")
var WorldUnlockedScene: PackedScene = preload("res://src/menus/jumbotrons/WorldUnlocked.tscn")
var ProgressPanelScene: PackedScene = preload("res://src/ui/components/PuzzleProgressPanel.tscn")

func on_puzzle_win(puzzle_node: DotHopPuzzle) -> void:
	var world := puzzle_node.world

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

	# TODO trace this and resupport it
	if already_complete:
		var end_of_world: bool = puzzle_num + 1 >= len(world.get_puzzles())
		if end_of_world:
			DotHop.notif("All puzzles complete!")
			await show_world_complete_jumbo(world)
			DotHop.nav_to_world_map()
		else:
			var next_puzzle_num: int = puzzle_num + 1
			show_progress_toast(next_puzzle_num, world)
			puzzle_num = next_puzzle_num
			DotHopPuzzle.rebuild_puzzle({
				puzzle_node=puzzle_node,
				puzzle_num=puzzle_num,
				})
	elif stats.puzzles_completed == stats.total_puzzles:
		DotHop.notif("All puzzles complete!")
		await show_no_more_puzzles_jumbo()
		DotHop.nav_to_credits()
	elif completed_world:
		DotHop.notif("Completed puzzle set!")
		await show_world_complete_jumbo(world)
		DotHop.nav_to_world_map()
	else:
		var puzzles: Array[PuzzleDef] = world.get_puzzles()
		var next_puzzle_num: int
		for i: int in range(puzzle_num, len(puzzles) + puzzle_num):
			i = i % len(puzzles)
			var puzz: PuzzleDef = puzzles[i]
			if not puzz.is_completed:
				next_puzzle_num = i
				break

		show_progress_toast(next_puzzle_num, world)
		puzzle_num = next_puzzle_num
		DotHopPuzzle.rebuild_puzzle({
			puzzle_node=puzzle_node,
			puzzle_num=puzzle_num,
			})

## progress toast #####################################################################

func show_progress_toast(next_puzzle_num: int, world: PuzzleWorld) -> void:
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
	# TODO restore this adding to hud
	add_child.call_deferred(panel)


## all puzzles jumbo #####################################################################

func show_world_complete_jumbo(world: PuzzleWorld) -> Signal:
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

func show_unlock_jumbo(world: PuzzleWorld) -> Signal:
	var instance: PuzzleUnlocked = WorldUnlockedScene.instantiate()
	instance.world = world
	return Jumbotron.jumbo_notif({pause=false, instance=instance})

## no more puzzles jumbo #####################################################################

func show_no_more_puzzles_jumbo() -> Signal:
	var instance: Node = WorldUnlockedScene.instantiate()
	return Jumbotron.jumbo_notif({pause=false, instance=instance})


## achievements ################################################################333

# TODO break into PuzzleAchievements node
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
