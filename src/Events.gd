extends Node
# autoload Events

var stats := Stats.new()

class Evt:
	func _init(opts: Dictionary) -> void:
		for k: String in opts.keys():
			if k in Evt:
				set(k, opts.get(k))

	var puzzle_def: PuzzleDef


class Stats:
	signal analysis_complete(evt: Evt)

	func fire_analysis_complete(puzzle_def: PuzzleDef) -> void:
		Log.info("[Event]", "analysis complete", puzzle_def)
		analysis_complete.emit(Evt.new({puzzle_def=puzzle_def}))
