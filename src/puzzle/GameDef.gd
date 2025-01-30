@tool
extends Object
class_name GameDef

## vars ########################################3333

var puzzles: Array[PuzzleDef] = []
var legend: Dictionary
var meta: Dictionary
var raw: Dictionary
var path: String

## init ########################################3333

func _init(_path: String, parsed: Dictionary) -> void:
	if _path:
		path = _path
	raw = parsed
	legend = parsed.legend
	var pzs: Array = parsed.puzzles
	puzzles.assign(pzs.map(func(puzzle: Dictionary) -> PuzzleDef: return PuzzleDef.new(puzzle)))

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
