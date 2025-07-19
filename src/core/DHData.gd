@tool
extends Object
class_name DHData


# Types of Dots
enum dotType { Dot=0, Dotted=1, Goal=2}

# Possible Grid Cell Object contents
enum Obj {
	Dot=0,
	Dotted=1,
	Goal=2,
	Player=3,
	Undo=4,
	}

static var puzzle_group: StringName = "dothop_puzzle"
static var reset_hold_t: float = 0.4

static func calc_stats(puzzle_sets: Array[PuzzleSet]) -> Dictionary:
	var total_puzzles: int = 0
	var puzzles_completed: int = 0
	var total_dots: int = 0
	var dots_hopped: int = 0

	for ps: PuzzleSet in puzzle_sets:
		for p: PuzzleDef in ps.get_puzzles():
			total_dots += p.dot_count()
			total_puzzles += 1
			if p.is_completed:
				puzzles_completed += 1
				dots_hopped += p.dot_count()

	return {
		total_dots=total_dots, dots_hopped=dots_hopped,
		total_puzzles=total_puzzles, puzzles_completed=puzzles_completed,
		}


# TODO drop 'player' in favor of 'start'

class Legend:
	static var default := {
		"." : [],
		"o" : [Obj.Dot],
		"t" : [Obj.Goal],
		"d" : [Obj.Dotted],
		"x" : [Obj.Player, Obj.Dotted],
		"u" : [Obj.Undo, Obj.Dotted],
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

	static func get_objs(letter: String) -> Array[Obj]:
		var objs: Array[Obj] = []
		objs.assign(Legend.default.get(letter, []) as Array)
		Log.pr("got objs for letter", letter, objs)
		return objs

		# # TODO any reason to do this in two steps? str -> [str] -> [objs] vs str -> [objs]?
		# var obj_names : Array[String] = default.get(letter, [])
		# objs.assign(obj_names.map(func(nm: String) -> Obj: return obj_map.get(nm)))
		# return objs
