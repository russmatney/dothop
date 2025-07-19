@tool
extends Resource
class_name PuzzleSetData

@export var display_name: String
@export var source_file: String

var parsed_game: ParsedGame
var puzzle_defs: Array[PuzzleDef] = []

## to pretty

func to_pretty() -> Variant:
	return {path=source_file, name=display_name, puzz_count=len(puzzle_defs)}

## setup ##################################################################

# we aren't yet serializing puzzle_defs and parsed_games (tho we could!)
# this would be a performance boost and we'd skip calling 'setup()' in places
func setup() -> void:
	Log.pr("Setting up PuzzleSetData", self)
	if parsed_game == null:
		var file := FileAccess.open(source_file, FileAccess.READ)
		if file == null:
			Log.error("FileAccess error while setting up puzzle set data", FileAccess.get_open_error(), source_file)
			return

		parsed_game = ParsedGame.parse(file.get_as_text())

	display_name = parsed_game.prelude.get("title", "Unnamed")
	puzzle_defs.assign(parsed_game.puzzles.map(func(puzzle: Dictionary) -> PuzzleDef:
		return PuzzleDef.new(puzzle)))

## create ##################################################################

static func from_contents(contents: String) -> PuzzleSetData:
	var parsed := ParsedGame.parse(contents)
	return PuzzleSetData.from_parsed_game(parsed)

static func from_path(path: String) -> PuzzleSetData:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		Log.error("FileAccess error while creating puzzle set data", FileAccess.get_open_error(), path)
		return

	var parsed := ParsedGame.parse(file.get_as_text())
	var psd := PuzzleSetData.from_parsed_game(parsed)
	psd.source_file = path
	return psd

static func from_parsed_game(parsed: ParsedGame = null) -> PuzzleSetData:
	var psd := PuzzleSetData.new()
	psd.parsed_game = parsed
	psd.setup()
	return psd
