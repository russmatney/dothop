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
	var psd := PuzzleSetData.new()
	psd.source_file = file
	psd.parsed_game = parsed
	psd.display_name = psd.parsed_game.prelude.get("title", "Unnamed")
	psd.puzzle_defs.assign(psd.parsed_game.puzzles.map(func(puzzle: Dictionary) -> PuzzleDef:
		return PuzzleDef.new(puzzle)))
	return psd
