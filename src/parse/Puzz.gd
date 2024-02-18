extends Node
class_name Puzz

static func parse_game_def(path, opts={}) -> GameDef:
	var contents = opts.get("contents")
	if path != null:
		if not FileAccess.file_exists(path):
			Log.error("Path does not exist! returning nil", path)
			return
		# could make sure file exists
		var file = FileAccess.open(path, FileAccess.READ)
		contents = file.get_as_text()

	var parsed = ParsedGame.new().parse(contents)
	return GameDef.new(path, parsed)

# helpful for supporting some tests
static func parse_puzzle_def(lines) -> PuzzleDef:
	return PuzzleDef.new(ParsedGame.new().parse_puzzle(lines))
