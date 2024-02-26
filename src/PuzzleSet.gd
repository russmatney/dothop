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

func allowed_in_demo() -> bool:
	return get_bool("allowed_in_demo")

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
		theme=get_theme().get_display_name(),
		completed=is_completed(),
		unlocked=is_unlocked(),
		}

## computed ############################################

# BEWARE OF CACHING!
var game_def: GameDef

# returns a cached game_def, or parses a new one
func get_game_def():
	if game_def != null:
		return game_def

	game_def = Puzz.parse_game_def(get_puzzle_script_path())
	return game_def

func get_puzzles():
	return get_game_def().puzzles.filter(func(puzz): return puzz.shape)

func get_puzzle(idx: int):
	var puzzs = get_puzzles()
	if idx < len(puzzs):
		return puzzs[idx]
	else:
		Log.warn("Requested out of range puzzle index", idx, self)

# Attach an "analysis" to each level_def (game_def.puzzles[])
# returns the game_def
func analyze_game_def():
	get_game_def() # ensure cache
	var puzzle_count = len(game_def.puzzles)
	for i in puzzle_count:
		var puzz_node = DotHopPuzzle.build_puzzle_node({game_def=game_def, puzzle_num=i})
		puzz_node.init_game_state()
		game_def.puzzles[i].analysis = PuzzleAnalysis.new(puzz_node).analyze()
	return game_def

func attach_game_def_stats():
	get_game_def() # ensure cache
	var puzzle_count = len(game_def.puzzles)
	for i in puzzle_count:
		var puzzle_def = game_def.puzzles[i]
		puzzle_def.is_completed = completed_puzzle(i)
		puzzle_def.is_skipped = skipped_puzzle(i)
	return game_def

## actions ############################################

func unlock():
	set_bool("is_unlocked", true)

func mark_complete():
	set_bool("is_completed", true)

var completed_puzzle_map = {}
func mark_puzzle_complete(puzzle_idx: int):
	completed_puzzle_map[puzzle_idx] = true

var skipped_puzzle_map = {}
func mark_puzzle_skipped(puzzle_idx: int):
	skipped_puzzle_map[puzzle_idx] = true
func mark_puzzle_not_skipped(puzzle_idx: int):
	skipped_puzzle_map.erase(puzzle_idx)

func update_max_index(puzzle_idx: int):
	var current = get_max_completed_puzzle_index()
	if puzzle_idx > current:
		set_integer("max_completed_puzzle_idx", puzzle_idx)

## public ############################################

func completed_puzzle(puzzle_idx: int):
	return completed_puzzle_map.get(puzzle_idx, false)

func skipped_puzzle(puzzle_idx: int):
	return skipped_puzzle_map.get(puzzle_idx, false)

# can play the puzzle number 1 greater than the max completed
func can_play_puzzle(puzzle_idx: int):
	return puzzle_idx <= 1 + get_max_completed_puzzle_index()

func completed_puzzle_count():
	var ct = 0
	for puz in get_puzzles():
		if puz.is_completed:
			ct += 1
	return ct

func skipped_puzzle_count():
	var ct = 0
	for puz in get_puzzles():
		if puz.is_skipped:
			ct += 1
	return ct
