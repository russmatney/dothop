@tool
extends Node

## _ready ###########################################

func _ready():
	load_game()

## data store ###########################################

var puzzle_sets: Array[PuzzleSet] = []
var themes: Array[DotHopTheme] = []

func save_game():
	SaveGame.save_game(get_tree(), {
		puzzle_sets=puzzle_sets.map(Pandora.serialize),
		themes=themes.map(Pandora.serialize),
		})

func load_game():
	var data = SaveGame.load_game(get_tree())

	# TODO merge/update puzzle set data when new ones are added or the parent entity is updated
	# this gets complicated - some fields should be updated and saved per user ('is_unlocked')
	# but others should be overwritable by changes to the data (i.e. some I should be able to
	# clear and unlock some puzzle set for a user, and rearrange the 'next-puzzle' bit)
	# maybe it's easier to save events like 'puzzle-set-2 completed'
	# and then reapply them to the initial data (which can change)

	if not "puzzle_sets" in data or len(data.puzzle_sets) == 0:
		puzzle_sets = initial_puzzle_sets()
	else:
		Log.pr("Loading saved puzzle sets")
		puzzle_sets.assign(data.puzzle_sets.map(Pandora.deserialize))
	Log.pr("Loaded %s puzzle sets" % len(puzzle_sets))

	if not "themes" in data or len(data.themes) == 0:
		themes = initial_themes()
	else:
		Log.pr("Loading saved themes")
		themes.assign(data.puzzle_sets.map(Pandora.deserialize))
	Log.pr("Loaded %s themes" % len(themes))

	# TODO validation and basic recovery on loaded data
	# i.e. missing puzzle_sets, at least set the initial ones and get to playable state

func reset_game_data():
	SaveGame.delete_save()
	load_game()

## initial data ###########################################

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

## repository ###########################################

func get_puzzle_sets() -> Array[PuzzleSet]:
	return puzzle_sets

func get_themes() -> Array[DotHopTheme]:
	return themes

func unlock_next_puzzle_set(puz: PuzzleSet):
	if puz.get_next_puzzle_set():
		var locked = puzzle_sets.filter(func(ps):
			return ps.get_entity_id() == puz.get_next_puzzle_set().get_entity_id())
		if len(locked) > 0:
			var next = locked[0]
			next.unlock()
			save_game()
	else:
		Log.warn("No next puzzle to unlock!", puz)
