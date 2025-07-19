@tool
extends Object
class_name GameState

var puzzle_sets: Array[PuzzleSet] = []
var themes: Array[PuzzleTheme] = []

## new #######################################################

func _init(events: Array = []) -> void:
	puzzle_sets = initial_puzzle_sets()
	themes = initial_themes()
	apply_events(events)
	attach_gameplay_data()

## apply events #######################################################

func apply_events(events: Array) -> void:
	Log.info("applying %s events, including (skipping puzzle-complete events)" % len(events),
		events\
		.filter(func(ev: Variant) -> bool:
			return not ev is PuzzleCompleted
			)\
		.map(func(e: Variant) -> String:
			if e == null: return "Null Event"
			return (e as Event).get_display_name()))

	for event: Event in events:
		apply_event(event)

func apply_event(event: Event) -> void:
	if event is PuzzleSetCompleted:
		var ps: PuzzleSet = find_puzzle_set((event as PuzzleSetCompleted).get_puzzle_set())
		if not ps:
			Log.warn("Could not apply event! No puzzle_set found.", event)
		ps.mark_complete()
	elif event is PuzzleCompleted:
		var ps: PuzzleSet = find_puzzle_set((event as PuzzleCompleted).get_puzzle_set())
		if not ps:
			Log.warn("Could not apply event! No puzzle_set found.", event)
		ps.mark_puzzle_complete((event as PuzzleCompleted).get_puzzle_index())
		ps.update_max_index((event as PuzzleCompleted).get_puzzle_index())
	elif event is PuzzleSkipped:
		var ps: PuzzleSet = find_puzzle_set((event as PuzzleSkipped).get_puzzle_set())
		if not ps:
			Log.warn("Could not apply event! No puzzle_set found.", event)
		if (event as PuzzleSkipped).is_active():
			ps.mark_puzzle_skipped((event as PuzzleSkipped).get_puzzle_index())
		else:
			ps.mark_puzzle_not_skipped((event as PuzzleSkipped).get_puzzle_index())
	elif event is PuzzleSetUnlocked:
		var ps: PuzzleSet = find_puzzle_set((event as PuzzleSetUnlocked).get_puzzle_set())
		if not ps:
			Log.warn("Could not apply event! No puzzle_set found.", event)
		ps.unlock()
	elif event is ThemeUnlocked:
		var th: PuzzleTheme = find_theme((event as ThemeUnlocked).get_theme())
		if not th:
			Log.warn("Could not apply event! No theme found.", event)
		th.unlock()
	else:
		Log.warn("Could not apply unhandled event", event)

## initial states #######################################################

func initial_puzzle_sets() -> Array[PuzzleSet]:
	var ent: PuzzleSet = Pandora.get_entity(PuzzleSetIDs.THEMDOTS)
	if ent == null:
		Log.warn("no THEMDOTS PuzzleSet entity found. Is Pandora data loaded?")
		return []
	var pss: Array = Pandora.get_all_entities(Pandora.get_category(ent._category_id))\
		.map(func(e: PandoraEntity) -> PuzzleSet: return e.instantiate())\
		.filter(func(e: PuzzleSet) -> bool:
			if OS.has_feature("demo"):
				return e.allowed_in_demo()
			return true)
	var ps: Array[PuzzleSet] = []
	ps.assign(pss)
	ps.sort_custom(func(a: PuzzleSet, b: PuzzleSet) -> bool: return a.get_sort_order() < b.get_sort_order())
	return ps

func initial_themes() -> Array[PuzzleTheme]:
	var ent: PuzzleTheme = Pandora.get_entity(PuzzleThemeIDs.DEBUG)
	if ent == null:
		Log.warn("no DEBUG theme entity found. Is Pandora data loaded?")
		return []
	var ths: Array = Pandora.get_all_entities(Pandora.get_category(ent._category_id))\
		.map(func(e: PandoraEntity) -> PuzzleTheme: return e.instantiate())
	var th: Array[PuzzleTheme] = []
	th.assign(ths)
	return th

## helpers #######################################################

func find_puzzle_set(ps: PuzzleSet) -> Variant:
	for puzz: PuzzleSet in puzzle_sets:
		# assumes puzzle_set instances and entities are 1:1, which seems fine
		if puzz.get_entity_id() == ps.get_entity_id():
			return puzz
	return

func find_theme(theme: PuzzleTheme) -> Variant:
	for th: PuzzleTheme in themes:
		# assumes puzzle_set instances and entities are 1:1, which seems fine
		if th.get_entity_id() == theme.get_entity_id():
			return th
	return

## stats ###########################################################

func attach_gameplay_data() -> void:
	Log.pr("attaching gameplay data")
	for ps: PuzzleSet in puzzle_sets:
		ps.attach_gameplay_data()
