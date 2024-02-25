@tool
extends Object
class_name GameState

var puzzle_sets: Array[PuzzleSet] = []
var themes: Array[PuzzleTheme] = []

## new #######################################################

func _init(events=[]):
	puzzle_sets = initial_puzzle_sets()
	themes = initial_themes()
	apply_events(events)

	compute_stats()

## apply events #######################################################

func apply_events(events):
	Log.prn("applying %s events, including" % len(events),
		events.filter(func(ev):
			return not ev is PuzzleCompleted)\
		.map(func(e): return e.get_display_name()))

	for event in events:
		apply_event(event)

func apply_event(event):
	if event is PuzzleSetCompleted:
		var ps = find_puzzle_set(event.get_puzzle_set())
		if not ps:
			Log.warn("Could not apply event! No puzzle_set found.", event)
		ps.mark_complete()
	elif event is PuzzleCompleted:
		var ps = find_puzzle_set(event.get_puzzle_set())
		if not ps:
			Log.warn("Could not apply event! No puzzle_set found.", event)
		ps.mark_puzzle_complete(event.get_puzzle_index())
		ps.update_max_index(event.get_puzzle_index())
	elif event is PuzzleSkipped:
		var ps = find_puzzle_set(event.get_puzzle_set())
		if not ps:
			Log.warn("Could not apply event! No puzzle_set found.", event)
		ps.mark_puzzle_skipped(event.get_puzzle_index())
	elif event is PuzzleSetUnlocked:
		var ps = find_puzzle_set(event.get_puzzle_set())
		if not ps:
			Log.warn("Could not apply event! No puzzle_set found.", event)
		ps.unlock()
	elif event is ThemeUnlocked:
		var th = find_theme(event.get_theme())
		if not th:
			Log.warn("Could not apply event! No theme found.", event)
		th.unlock()
	else:
		Log.warn("Could not apply unhandled event", event)

## initial states #######################################################

func initial_puzzle_sets() -> Array[PuzzleSet]:
	var ent = Pandora.get_entity(PuzzleSetIDs.ONE)
	var pss = Pandora.get_all_entities(Pandora.get_category(ent._category_id))\
		.map(func(e): return e.instantiate())\
		.filter(func(e):
			if OS.has_feature("demo"):
				return e.allowed_in_demo()
			return true)
	var ps: Array[PuzzleSet] = []
	ps.assign(pss)
	ps.sort_custom(func(a, b): return a.get_sort_order() < b.get_sort_order())
	return ps

func initial_themes() -> Array[PuzzleTheme]:
	var ent = Pandora.get_entity(PuzzleThemeIDs.DEBUG)
	var ths = Pandora.get_all_entities(Pandora.get_category(ent._category_id))\
		.map(func(e): return e.instantiate())
	var th: Array[PuzzleTheme] = []
	th.assign(ths)
	return th

## helpers #######################################################

func find_puzzle_set(ps: PuzzleSet):
	for puzz in puzzle_sets:
		# assumes puzzle_set instances and entities are 1:1, which seems fine
		if puzz.get_entity_id() == ps.get_entity_id():
			return puzz

func find_theme(theme: PuzzleTheme):
	for th in themes:
		# assumes puzzle_set instances and entities are 1:1, which seems fine
		if th.get_entity_id() == theme.get_entity_id():
			return th

## stats ###########################################################

func compute_stats():
	for ps in puzzle_sets:
		ps.attach_game_def_stats()
