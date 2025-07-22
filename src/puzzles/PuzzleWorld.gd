@tool
extends PandoraEntity
class_name PuzzleWorld

## properties ##########################################

func get_puzzle_script_path() -> String:
	return get_string("puzzle_script_path")

var cached_psd: PuzzleSetData

func get_puzzle_set_data() -> PuzzleSetData:
	if cached_psd != null:
		return cached_psd
	cached_psd = get_resource("puzzle_set_data")
	cached_psd.setup()
	return cached_psd

func get_theme_data() -> PuzzleThemeData:
	return get_resource("theme_data")

func get_puzzle_scene() -> PackedScene:
	return get_theme_data().puzzle_scene

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

func get_max_completed_puzzle_index() -> int:
	return get_integer("max_completed_puzzle_idx")

func get_sort_order() -> int:
	return get_integer("sort_order")

func get_puzzles_to_unlock() -> int:
	return get_integer("puzzles_to_unlock")

## all properties (consumed by Log.gd) #################

func data() -> Variant:
	return {
		puzzle_set_data=get_puzzle_set_data(),
		name=get_display_name(),
		completed=is_completed(),
		unlocked=is_unlocked(),
		}

## computed ############################################

func get_puzzles() -> Array[PuzzleDef]:
	return get_puzzle_set_data().puzzle_defs.filter(func(puzz: PuzzleDef) -> bool: return puzz.shape != null)

func get_puzzle(idx: int) -> PuzzleDef:
	var puzzs: Array[PuzzleDef] = get_puzzles()
	if idx < len(puzzs):
		return puzzs[idx]
	else:
		Log.warn("Requested out of range puzzle index", idx, self)
		return

# Attach an "analysis" to each puzzle_def
func analyze_puzzles() -> PuzzleSetData:
	var psd := get_puzzle_set_data()
	var puzzle_count: int = len(psd.puzzle_defs)
	for i: int in puzzle_count:
		if psd.puzzle_defs[i].analysis == null:
			Log.info("analyzing puzzle", get_display_name(), i)
			var puzz_state := PuzzleState.new(psd.puzzle_defs[i])
			psd.puzzle_defs[i].analysis = PuzzleAnalysis.new({state=puzz_state}).analyze()
			Log.info("analyzed puzzle", get_display_name(), i)
		else:
			pass # using cached analysis
	return psd

func analyze_puzzles_in_bg() -> Thread:
	var th: Thread = Thread.new()
	th.start(analyze_puzzles)
	return th

func attach_gameplay_data() -> PuzzleSetData:
	var psd := get_puzzle_set_data()
	for i: int in len(psd.puzzle_defs):
		var puzzle_def: PuzzleDef = psd.puzzle_defs[i]
		puzzle_def.is_completed = completed_puzzle(i)
		puzzle_def.is_skipped = skipped_puzzle(i)
	return psd

## actions ############################################

func unlock() -> void:
	set_bool("is_unlocked", true)

func mark_complete() -> void:
	set_bool("is_completed", true)

var completed_puzzle_map: Dictionary = {}
func mark_puzzle_complete(puzzle_idx: int) -> void:
	completed_puzzle_map[puzzle_idx] = true

var skipped_puzzle_map: Dictionary = {}
func mark_puzzle_skipped(puzzle_idx: int) -> void:
	skipped_puzzle_map[puzzle_idx] = true
func mark_puzzle_not_skipped(puzzle_idx: int) -> void:
	skipped_puzzle_map.erase(puzzle_idx)

func update_max_index(puzzle_idx: int) -> void:
	var current: int = get_max_completed_puzzle_index()
	if puzzle_idx > current:
		set_integer("max_completed_puzzle_idx", puzzle_idx)

## public ############################################

func completed_puzzle(puzzle_idx: int) -> bool:
	return completed_puzzle_map.get(puzzle_idx, false)

func skipped_puzzle(puzzle_idx: int) -> bool:
	return skipped_puzzle_map.get(puzzle_idx, false)

# can play the puzzle number 1 greater than the max completed
func can_play_puzzle(puzzle_idx: int) -> bool:
	var _max: int = get_max_completed_puzzle_index()
	if puzzle_idx < _max:
		return true

	var puzzles_ahead: int = 3 + _max # farthest possible
	for i: int in range(_max):
		if not completed_puzzle(i):
			puzzles_ahead -= 1 # subtract for incomplete levels

	return puzzle_idx <= puzzles_ahead

func completed_puzzle_count() -> int:
	var ct: int = 0
	for puz: PuzzleDef in get_puzzles():
		if puz.is_completed:
			ct += 1
	return ct

func skipped_puzzle_count() -> int:
	var ct: int = 0
	for puz: PuzzleDef in get_puzzles():
		if puz.is_skipped:
			ct += 1
	return ct
