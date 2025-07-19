@tool
extends Resource
class_name PuzzleSetData

@export var display_name: String
@export var source_file: String

var parsed_game: ParsedGame
var puzzle_defs: Array[PuzzleDef] = []

## to pretty

func to_pretty() -> Variant:
	return [source_file, display_name]

## create ##################################################################

static func create(file: String, parsed: ParsedGame = null) -> PuzzleSetData:
	var psd := PuzzleSetData.from_parsed_game(parsed)
	psd.source_file = file
	return psd

static func from_contents(contents: String) -> PuzzleSetData:
	var parsed := ParsedGame.parse(contents)
	return PuzzleSetData.from_parsed_game(parsed)

static func from_parsed_game(parsed: ParsedGame = null) -> PuzzleSetData:
	var psd := PuzzleSetData.new()
	psd.parsed_game = parsed
	psd.display_name = parsed.prelude.get("title", "Unnamed")
	psd.puzzle_defs.assign(parsed.puzzles.map(func(puzzle: Dictionary) -> PuzzleDef:
		return PuzzleDef.new(puzzle)))
	return psd
