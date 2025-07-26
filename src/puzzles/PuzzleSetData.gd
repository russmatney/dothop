@tool
extends Resource
class_name PuzzleSetData

@export var display_name: String
@export var source_file: String

@export var parsed_game: ParsedGame
var puzzle_defs: Array[PuzzleDef] = []

## to pretty

func to_pretty() -> Variant:
	return {path=source_file, name=display_name, puzz_count=len(puzzle_defs)}

## setup ##################################################################

# we aren't yet serializing puzzle_defs yet, so here we create and assign them
# TODO drop the need for this setup situation
func setup() -> void:
	if len(puzzle_defs) > 0:
		# TODO remove (probably this whole func will go, but for now this helps us trace that)
		Log.info("Skipping PuzzleSetData setup, already have puzzle_defs", self)
		return
	if parsed_game == null:
		Log.error("parsed_game is null! Has this .puzz been imported?", source_file)
		return

	display_name = parsed_game.prelude.get("title", "Unnamed")
	puzzle_defs.assign(parsed_game.puzzles.map(func(puzzle: Dictionary) -> PuzzleDef:
		return PuzzleDef.new(puzzle)))

	Log.info("Set up PuzzleSetData", self)

## create ##################################################################

static func from_contents(contents: String) -> PuzzleSetData:
	var parsed := ParsedGame.parse(contents)
	return PuzzleSetData.from_parsed_game(parsed)

static func from_path(path: String) -> PuzzleSetData:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		Log.error("FileAccess error while parsing puzzle data", FileAccess.get_open_error(), path)
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
