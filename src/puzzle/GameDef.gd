@tool
extends Object
class_name GameDef

## vars ########################################3333

var puzzles = []
var legend: Dictionary
var meta: Dictionary
var raw: Dictionary
var path: String

## init ########################################3333

func _init(_path, parsed: Dictionary):
	if _path:
		path = _path
	raw = parsed
	legend = parsed.legend
	puzzles = parsed.puzzles.map(func(puzzle): return PuzzleDef.new(puzzle))

## log.data() ########################################3333

func data():
	return {path=path, obj=str(self), puzzles=len(puzzles)}

## helpers ########################################3333

# convert passed legend input into a list of strings
func get_cell_objects(cell):
	if cell == null:
		return

	var objs = legend.get(cell)
	if objs != null:
		# duplicate, so the returned array doesn't share state with every other cell
		objs = objs.duplicate()

	if objs != null:
		objs = objs.map(func(n):
			if n in ["PlayerA", "PlayerB"]:
				return "Player"
			else:
				return n)

	return objs
