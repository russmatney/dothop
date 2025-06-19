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

# finally baking the legend into the code directly
static var default_legend := {
	"." : ["Background"],
	"o" : ["Dot"],
	"t" : ["Goal"],
	"x" : ["Player", "Dotted"], #consider dropping 'player' and supporting a clearer 'start'
	}

static func from_puzzle(puzzle: Array) -> GameDef:
	# gross - wtf is going on with these constructors
	var parsed_game := ParsedGame.new()
	var puzz_def := PuzzleDef.new(parsed_game.parse_puzzle(puzzle) as Dictionary)
	parsed_game.legend = default_legend
	var game_def := GameDef.new(null, parsed_game)
	game_def.puzzles = [puzz_def]
	return game_def

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

enum Obj {
	Dot=0,
	Dotted=1,
	Goal=2,
	Player=3,
	Undo=4,
	}

static var obj_map: Dictionary[String, Obj] = {
	Dot=Obj.Dot,
	Dotted=Obj.Dotted,
	Goal=Obj.Goal,
	Player=Obj.Player,
	PlayerA=Obj.Player,
	PlayerB=Obj.Player,
	Undo=Obj.Undo,
	}

static var reverse_obj_map: Dictionary[Obj, String] = {
	Obj.Dot: "Dot",
	Obj.Dotted: "Dotted",
	Obj.Goal: "Goal",
	Obj.Player: "Player",
	Obj.Undo: "Undo",
	}

static func obj_name_to_type(n: String) -> Variant:
	if n in GameDef.obj_map:
		return GameDef.obj_map[n]

	Log.error("Unknown object type in legend", n)
	return null

static func obj_type_to_name(t: Obj) -> String:
	if t in GameDef.reverse_obj_map:
		return GameDef.reverse_obj_map[t]

	Log.error("Unknown object type in reverse map", t)
	return "Unknown"

class GridCell:
	var coord: Vector2i
	var objs: Array[Obj]

	func _init(x: int, y: int, _objs: Array[String]) -> void:
		coord = Vector2i(x, y)
		var os := _objs.map(GameDef.obj_name_to_type)
		os = U.remove_nulls(os)
		objs.assign(os)

# depends on the game def instance's parsed legend
func grid_cells(puzzle_def: PuzzleDef) -> Array[GridCell]:
	var cells: Array[GridCell] = []
	for y in range(len(puzzle_def.shape)):
		for x in range(len(puzzle_def.shape[0])):
			var os: Array = legend.get(puzzle_def.shape[y][x], [])
			var objs: Array[String] = []
			objs.assign(os)
			cells.append(GridCell.new(x, y, objs))
	return cells

# convert passed legend input into a list of enums
func get_cell_objects(cell: Variant) -> Variant:
	if cell == null:
		return

	var objs: Array = legend.get(cell, [])
	# duplicate, so the returned array doesn't share state with every other cell
	objs = objs.duplicate()
	# map to Obj enum
	objs = objs.map(GameDef.obj_name_to_type)
	objs = U.remove_nulls(objs)

	return objs
