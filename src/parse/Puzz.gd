extends Node
class_name Puzz

static func parse_game_def(path: Variant, opts: Dictionary = {}) -> GameDef:
	var contents: String = opts.get("contents", "")
	if path != null:
		if not FileAccess.file_exists(path as String):
			Log.error("Path does not exist! returning nil", path)
			return
		# could make sure file exists
		var file: FileAccess = FileAccess.open(path as String, FileAccess.READ)
		contents = file.get_as_text()

	var parsed: Dictionary = ParsedGame.new().parse(contents)
	return GameDef.new(path, parsed)

# helpful for supporting some tests
static func parse_puzzle_def(lines: Array) -> PuzzleDef:
	return PuzzleDef.new(ParsedGame.new().parse_puzzle(lines) as Dictionary)
