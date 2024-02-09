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

## apply events #######################################################

func apply_events(events):
	Log.pr("applying %s events" % len(events), events.map(func(e): return e.get_display_name()))

	for event in events:
		apply_event(event)

func apply_event(event):
	if event is PuzzleSetCompleted:
		var ps = find_puzzle_set(event.get_puzzle_set())
		if not ps:
			Log.warn("Could not apply event! No puzzle_set found.", event)
		ps.mark_complete()
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

## initial states #######################################################

func initial_puzzle_sets() -> Array[PuzzleSet]:
	var ent = Pandora.get_entity(PuzzleSetIDs.ONE)
	var pss = Pandora.get_all_entities(Pandora.get_category(ent._category_id))\
		.map(func(e): return e.instantiate())
	var ps: Array[PuzzleSet] = []
	ps.assign(pss)
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
