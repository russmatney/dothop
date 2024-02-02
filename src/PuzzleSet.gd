@tool
extends PandoraEntity
class_name PuzzleSet

## properties ##########################################

func get_puzzle_script_path() -> String:
	return get_string("puzzle_script_path")

func get_display_name() -> String:
	return get_string("display_name")

func get_theme() -> DotHopTheme:
	return get_resource("theme")

func get_icon_texture() -> Texture:
	return get_resource("icon_texture")

func is_completed() -> bool:
	return get_bool("is_completed")

func is_unlocked() -> bool:
	return get_bool("is_unlocked")

func get_next_puzzle_set() -> PuzzleSet:
	return get_reference("next_set")

## all properties (consumed by Log.gd) #################

func data():
	return {
		puzzle_script_path=get_puzzle_script_path(),
		name=get_display_name(),
		theme=get_theme(),
		icon_texture=get_icon_texture(),
		completed=is_completed(),
		unlocked=is_unlocked(),
		}

## computed ############################################

# BEWARE OF CACHING!
var game_def
var analyzed_game_def

# TODO create type for game_def, with level_def/analysis, etc?

# returns a cached game_def, or parses a new one
func get_game_def():
	if analyzed_game_def != null:
		return analyzed_game_def
	if game_def != null:
		return game_def
	game_def = Puzz.parse_game_def(get_puzzle_script_path())
	return game_def

func get_puzzles():
	return get_game_def().levels.filter(func(puzz): return puzz.shape)

# Attach an "analysis" to each level_def (game_def.levels[])
# returns the game_def
func get_analyzed_game_def():
	if analyzed_game_def != null:
		return analyzed_game_def

	get_game_def() # ensure cache
	var level_count = len(game_def.levels)
	for i in level_count:
		var puzz_node = DotHopPuzzle.build_puzzle_node({game_def=game_def, puzzle_num=i})
		game_def.levels[i]["analysis"] = Solver.new(puzz_node).analyze()

	analyzed_game_def = game_def
	return analyzed_game_def

## actions ############################################

func unlock():
	set_bool("is_unlocked", true)

func mark_complete():
	set_bool("is_completed", true)
