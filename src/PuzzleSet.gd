@tool
extends PandoraEntity
class_name PuzzleSet

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

func data():
	return {
		puzzle_script_path=get_puzzle_script_path(),
		name=get_display_name(),
		theme=get_theme(),
		icon_texture=get_icon_texture(),
		completed=is_completed(),
		unlocked=is_unlocked(),
		}

##############################################

func get_game_def():
	return Puzz.parse_game_def(get_puzzle_script_path())

func get_puzzles():
	var def = get_game_def()
	return def.levels.filter(func(puzz): return puzz.shape)

func unlock():
	set_bool("is_unlocked", true)

func mark_complete():
	set_bool("is_completed", true)
