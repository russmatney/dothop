@tool
extends Object
class_name GameDef

static func parse_game_def(_path: Variant, opts: Dictionary = {}) -> GameDef:
	var contents: String = opts.get("contents", "")
	if _path != null:
		if not FileAccess.file_exists(_path as String):
			Log.error("Path does not exist! returning nil", _path)
			return
		# could make sure file exists
		var file: FileAccess = FileAccess.open(_path as String, FileAccess.READ)
		contents = file.get_as_text()

	var parsed_game: ParsedGame = ParsedGame.parse(contents)
	return GameDef.new(_path, parsed_game)

# helpful for supporting some tests
static func parse_puzzle_def(lines: Array) -> PuzzleDef:
	return PuzzleDef.new(ParsedGame.new().parse_puzzle(lines) as Dictionary)

## vars ########################################3333

var puzzles: Array[PuzzleDef] = []
var legend: Dictionary
var meta: Dictionary
var parsed: ParsedGame
var path: String

## init ########################################3333

func _init(_path: Variant, _parsed: ParsedGame) -> void:
	if _path != null:
		path = _path
	parsed = _parsed
	legend = parsed.legend
	puzzles.assign(parsed.puzzles.map(func(puzzle: Dictionary) -> PuzzleDef:
		return PuzzleDef.new(puzzle)))

## to_pretty ########################################3333

func to_pretty() -> Dictionary:
	return {path=path, obj=str(self), puzzles=len(puzzles)}

## helpers ########################################3333

# convert passed legend input into a list of strings
func get_cell_objects(cell: Variant) -> Variant:
	if cell == null:
		return

	var objs: Array = legend.get(cell, [])
	# duplicate, so the returned array doesn't share state with every other cell
	objs = objs.duplicate()
	objs = objs.map(func(n: String) -> String:
		if n in ["PlayerA", "PlayerB"]:
			return "Player"
		else:
			return n)

	return objs
