@tool
extends Object
class_name GameState

var puzzle_sets: Array[PuzzleSet] = []
var themes: Array[DotHopTheme] = []

## new #######################################################

func _init(events=[]):
	Log.pr("Creating game state with %d events" % len(events))
	puzzle_sets = initial_puzzle_sets()
	themes = initial_themes()
	apply_events(events)

## apply events #######################################################

func apply_events(events):
	# do we need to sort by timestamp? does application order matter?
	for event in events:
		apply_event(event)

func apply_event(event):
	# TODO branch on event type
	# unlock the referenced puzzle_set
	# mark the referenced puzzle_set complete

	pass

## initial states #######################################################

func initial_puzzle_sets() -> Array[PuzzleSet]:
	var ent = Pandora.get_entity(PuzzleSetIDs.ONE)
	var pss = Pandora.get_all_entities(Pandora.get_category(ent._category_id))\
		.map(func(e): return e.instantiate())
	var ps: Array[PuzzleSet] = []
	ps.assign(pss)
	return ps

func initial_themes() -> Array[DotHopTheme]:
	var ent = Pandora.get_entity(PuzzleThemeIDs.DEBUG)
	var ths = Pandora.get_all_entities(Pandora.get_category(ent._category_id))\
		.map(func(e): return e.instantiate())
	var th: Array[DotHopTheme] = []
	th.assign(ths)
	return th
