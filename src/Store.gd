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

	if not "puzzle_sets" in data or len(data.puzzle_sets) == 0:
		puzzle_sets = initial_puzzle_sets()
		Log.pr("Loaded %s puzzle_sets" % len(puzzle_sets))
	else:
		puzzle_sets.assign(data.puzzle_sets.map(Pandora.deserialize))

	if not "themes" in data or len(data.themes) == 0:
		themes = initial_themes()
		Log.pr("Loaded %s themes" % len(themes))
	else:
		themes.assign(data.puzzle_sets.map(Pandora.deserialize))

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
