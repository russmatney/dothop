@tool
extends PandoraEntity
class_name PuzzleSet

## properties ##########################################

func get_puzzle_script_path() -> String:
	return get_string("puzzle_script_path")

func get_display_name() -> String:
	return get_string("display_name")

func get_theme() -> PuzzleTheme:
	return get_resource("theme")

func get_icon_texture() -> Texture:
	return get_resource("icon_texture")

func get_worldmap_island_texture() -> Texture:
	return get_resource("worldmap_island_texture")

func is_completed() -> bool:
	return get_bool("is_completed")

func is_unlocked() -> bool:
	return get_bool("is_unlocked")

func get_next_puzzle_set() -> PuzzleSet:
	return get_reference("next_set")

func get_max_completed_puzzle_index() -> int:
	return get_integer("max_completed_puzzle_idx")

func get_sort_order() -> int:
	return get_integer("sort_order")

## all properties (consumed by Log.gd) #################

func data():
	return {
		puzzle_script_path=get_puzzle_script_path(),
		name=get_display_name(),
		theme=get_theme(),
		icon_texture=get_icon_texture(),
		completed=is_completed(),
		unlocked=is_unlocked(),
		max_puzzle_idx=get_max_completed_puzzle_index(),
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

func get_puzzle(idx: int):
	var puzzs = get_puzzles()
	if idx < len(puzzs):
		return puzzs[idx]
	else:
		Log.warn("Requested out of range puzzle index", idx, self)

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

func update_max_index(idx: int):
	var current = get_max_completed_puzzle_index()
	if idx > current:
		set_integer("max_completed_puzzle_idx", idx)

## public ############################################

func completed_puzzle(idx: int):
	return idx <=  get_max_completed_puzzle_index()

# can play the puzzle number 1 greater than the max completed
func can_play_puzzle(idx: int):
	return idx <= 1 + get_max_completed_puzzle_index()
