@tool
extends Node

## _ready ###########################################

func _enter_tree() -> void:
	load_game()

## data store ###########################################

var state: GameState

var events: Array[Event] = []

func save_game() -> void:
	events.map(func(ev: Event) -> void:
		if ev == null: Log.warn("Cannot save null event!", ev)
		)
	SaveGame.save_game(get_tree(), {
		events=events.filter(func(ev: Event) -> bool: return ev != null)\
		.map(Pandora.serialize),
		})

# validation and basic recovery from crashes on loaded data?
# i.e. missing puzzle_sets, at least set the initial ones and get to playable state
func load_game() -> void:
	var data: Dictionary = SaveGame.load_game(get_tree())

	if not "events" in data or len(data.events) == 0:
		events = initial_events()
	else:
		events.assign((data.events as Array)\
			.filter(func(ev: Event) -> bool: return ev != null)\
			# TODO handle crashes when events can't deserialize
			.map(Pandora.deserialize))

	state = GameState.new(events)

	Log.pr("Loaded data", {
		events=len(events), puzzle_sets=len(state.puzzle_sets), themes=len(state.themes)
		})

func reset_game_data() -> void:
	SaveGame.delete_save()
	load_game()

## initial data ###########################################

func initial_events() -> Array[Event]:
	return []

## repository ###########################################

func get_puzzle_sets() -> Array[PuzzleSet]:
	return state.puzzle_sets

func find_puzzle_set(ps: PuzzleSet) -> PuzzleSet:
	return state.find_puzzle_set(ps)

func get_themes() -> Array[PuzzleTheme]:
	return state.themes

func get_events() -> Array[Event]:
	return events

func find_events(filter_fn: Callable) -> Array[Event]:
	return events.filter(filter_fn)

func find_event(filter_fn: Callable) -> Event:
	var evs: Array = find_events(filter_fn)
	if len(evs) > 0:
		return evs[0]
	else:
		return null

## events ###########################################

func complete_puzzle_set(puz: PuzzleSet) -> void:
	var event: PuzzleSetCompleted = find_event(func(ev: Event) -> bool: return PuzzleSetCompleted.is_matching_event(ev, puz))
	if event:
		event.inc_count()
	elif not event:
		event = PuzzleSetCompleted.new_event(puz)
		state.apply_event(event)
		events.append(event)
	save_game()

func complete_puzzle_index(puz: PuzzleSet, idx: int) -> void:
	var event: PuzzleCompleted = find_event(func(ev: Event) -> bool: return PuzzleCompleted.is_matching_event(ev, puz, idx))
	if event:
		event.inc_count()
	elif not event:
		event = PuzzleCompleted.new_event(puz, idx)
		state.apply_event(event)
		events.append(event)

	var skip_event: Event = find_event(func(ev: Event) -> bool:
		return PuzzleSkipped.is_matching_event(ev, puz, idx) and (ev as PuzzleSkipped).is_active())
	if skip_event:
		(skip_event as PuzzleSkipped).mark_inactive()
		# NOTE the in-place (passed) puzzle set is not updated
		state.apply_event(skip_event)

	@warning_ignore("unsafe_method_access")
	var p: PuzzleSet = state.find_puzzle_set(event.get_puzzle_set() as PuzzleSet)
	p.attach_game_def_stats()

	save_game()

func skip_puzzle(puz: PuzzleSet, idx: int) -> void:
	var event: PuzzleSkipped = find_event(func(ev: Event) -> bool: return PuzzleSkipped.is_matching_event(ev, puz, idx))
	if event:
		event.inc_count()
	elif not event:
		event = PuzzleSkipped.new_event(puz, idx)
		state.apply_event(event)
		events.append(event)

	# recompute completes/skips on puzzle_defs
	puz.attach_game_def_stats()

	save_game()

func unlock_puzzle_set(puz: PuzzleSet) -> void:
	var event: Event = find_event(func(ev: Event) -> bool: return PuzzleSetUnlocked.is_matching_event(ev, puz))
	if event:
		event.inc_count()
	elif not event:
		event = PuzzleSetUnlocked.new_event(puz)
		state.apply_event(event)
		events.append(event)

	# save update events for later reloading
	save_game()

# Deprecated
func unlock_next_puzzle_set(puz: PuzzleSet) -> void:
	var next: PuzzleSet = puz.get_next_puzzle_set()
	if next:
		unlock_puzzle_set(next)
	else:
		Log.warn("No next puzzle to unlock!", puz)

func unlock_all_puzzle_sets() -> void:
	Log.warn("Unlocking all puzzle sets!")
	for ps: PuzzleSet in state.puzzle_sets:
		var event: PuzzleSetUnlocked = find_event(func(ev: Event) -> bool: return PuzzleSetUnlocked.is_matching_event(ev, ps))
		if event:
			continue
		event = PuzzleSetUnlocked.new_event(ps)
		state.apply_event(event)
		events.append(event)
	save_game()
