@tool
extends Object
class_name GameDef

# TODO punt this to DHData
# finally baking the legend into the code directly
# TODO support 'u' in the legend (for easier undo tests?)
# TODO support some kind of 'dotted' in the legend (maybe d?)
# TODO drop 'player' in favor of 'start'
# TODO parse directly into enums here
static var default_legend := {
	"." : ["Background"],
	"o" : ["Dot"],
	"t" : ["Goal"],
	"x" : ["Player", "Dotted"],
	}

## vars ########################################3333

var puzzles: Array[PuzzleDef] = []
var legend: Dictionary
var meta: Dictionary
var parsed: ParsedGame
var path: String

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

	# func has_player():
	# 	return Obj.Player in objs
	# func has_goal():
	# 	return Obj.Goal in objs
	# func has_dot():
	# 	return Obj.Dot in objs
	# func has_dotted():
	# 	return Obj.Dotted in objs

# depends on the game def instance's parsed legend
static func grid_cells(puzzle_def: PuzzleDef) -> Array[GridCell]:
	var cells: Array[GridCell] = []
	for y in range(len(puzzle_def.shape)):
		for x in range(len(puzzle_def.shape[0])):
			var os: Array = default_legend.get(puzzle_def.shape[y][x], [])
			var objs: Array[String] = []
			objs.assign(os)
			cells.append(GridCell.new(x, y, objs))
	return cells
