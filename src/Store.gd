@tool
extends Node

## _ready ###########################################

func _enter_tree():
	load_game()

## data store ###########################################

var state: GameState

var events: Array[Event] = []

func save_game():
	SaveGame.save_game(get_tree(), {
		events=events.map(Pandora.serialize),
		})

# validation and basic recovery from crashes on loaded data?
# i.e. missing puzzle_sets, at least set the initial ones and get to playable state
func load_game():
	var data = SaveGame.load_game(get_tree())

	if not "events" in data or len(data.events) == 0:
		events = initial_events()
	else:
		# TODO handle crashes when events can't deserialize
		events.assign(data.events.map(Pandora.deserialize))

	state = GameState.new(events)

	Log.pr("Loaded data", {
		events=len(events), puzzle_sets=len(state.puzzle_sets), themes=len(state.themes)
		})

func reset_game_data():
	SaveGame.delete_save()
	load_game()

## initial data ###########################################

func initial_events() -> Array[Event]:
	return []

## repository ###########################################

func get_puzzle_sets() -> Array[PuzzleSet]:
	return state.puzzle_sets

func get_themes() -> Array[PuzzleTheme]:
	return state.themes

func get_events() -> Array[Event]:
	return events

func find_events(filter_fn) -> Array[Event]:
	return events.filter(filter_fn)

func find_event(filter_fn) -> Event:
	var evs = find_events(filter_fn)
	if len(evs) > 0:
		return evs[0]
	else:
		return null

## events ###########################################

func complete_puzzle_set(puz: PuzzleSet):
	var event = find_event(func(ev): return PuzzleSetCompleted.is_matching_event(ev, puz))
	if event:
		event.inc_count()
	elif not event:
		event = PuzzleSetCompleted.new_event(puz)
		state.apply_event(event)
		events.append(event)
	save_game()

	# TODO abstract out achievements
	match (puz.get_entity_id()):
		PuzzleSetIDs.ONE: GodotSteam.set_them_dots_complete()
		PuzzleSetIDs.FIVE: GodotSteam.set_spring_in_your_hop_complete()
		PuzzleSetIDs.FOUR: GodotSteam.set_thats_just_beachy_complete()
		PuzzleSetIDs.THREE: GodotSteam.set_leaf_me_alone_complete()
		PuzzleSetIDs.SIX: GodotSteam.set_snow_way_complete()
		PuzzleSetIDs.TWO:
			GodotSteam.set_get_outer_here_complete()
			# TODO this may not be true if they've 'unlocked' and then come straight here
			GodotSteam.set_all_puzzles_complete()

	if puz.get_next_puzzle_set():
		unlock_next_puzzle_set(puz)

func complete_puzzle_index(puz: PuzzleSet, idx: int):
	var event = find_event(func(ev): return PuzzleCompleted.is_matching_event(ev, puz, idx))
	if event:
		event.inc_count()
	elif not event:
		event = PuzzleCompleted.new_event(puz, idx)
		state.apply_event(event)
		events.append(event)

	var skip_event = find_event(func(ev):
		return PuzzleSkipped.is_matching_event(ev, puz, idx) and ev.is_active())
	if skip_event:
		skip_event.mark_inactive()
		# NOTE the in-place (passed) puzzle set is not updated
		state.apply_event(skip_event)

	var p = state.find_puzzle_set(event.get_puzzle_set())
	p.attach_game_def_stats()

	save_game()

	var dot_counts = dots_hopped()
	if dot_counts.dots_hopped > 10:
		GodotSteam.set_ten_dots()
	if dot_counts.dots_hopped > 50:
		GodotSteam.set_fifty_dots()
	if dot_counts.dots_hopped > 100:
		GodotSteam.set_one_hundred_dots()
	if dot_counts.dots_hopped > 500:
		GodotSteam.set_five_hundred_dots()
	if dot_counts.dots_hopped > 1 and dot_counts.dots_hopped == dot_counts.total_dots:
		GodotSteam.set_all_the_dots()

# TODO DRY up count against the main menu stat calc
func dots_hopped():
	var total_dots = 0
	var _dots_hopped = 0

	for ps in Store.get_puzzle_sets():
		for p in ps.get_puzzles():
			total_dots += p.dot_count()
			if p.is_completed:
				_dots_hopped += p.dot_count()

	return {total_dots=total_dots, dots_hopped=_dots_hopped}


func skip_puzzle(puz: PuzzleSet, idx: int):
	var event = find_event(func(ev): return PuzzleSkipped.is_matching_event(ev, puz, idx))
	if event:
		event.inc_count()
	elif not event:
		event = PuzzleSkipped.new_event(puz, idx)
		state.apply_event(event)
		events.append(event)

	# recompute completes/skips on puzzle_defs
	puz.attach_game_def_stats()

	save_game()

func unlock_next_puzzle_set(puz: PuzzleSet):
	var next = puz.get_next_puzzle_set()
	if next:
		var event = find_event(func(ev): return PuzzleSetUnlocked.is_matching_event(ev, next))
		if event:
			event.inc_count()
		elif not event:
			event = PuzzleSetUnlocked.new_event(next)
			state.apply_event(event)
			events.append(event)

		# save update events for later reloading
		save_game()
	else:
		Log.warn("No next puzzle to unlock!", puz)

func unlock_all_puzzle_sets():
	Log.warn("Unlocking all puzzle sets!")
	for ps in state.puzzle_sets:
		var event = find_event(func(ev): return PuzzleSetUnlocked.is_matching_event(ev, ps))
		if event:
			continue
		event = PuzzleSetUnlocked.new_event(ps)
		state.apply_event(event)
		events.append(event)
	save_game()
