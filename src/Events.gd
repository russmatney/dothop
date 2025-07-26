extends Node
# autoload Events

var stats := Stats.new()
var puzzle_node := PuzzleNode.new()

class Evt:
	func _init(opts: Dictionary) -> void:
		puzzle_def = opts.get("puzzle_def")
		puzzle_node = opts.get("puzzle_node")
		# thought this'd just-work?
		# for k: String in opts.keys():
		# 	if k in Evt:
		# 		set(k, opts.get(k))

		Log.info("new event", self)

	func to_pretty() -> Variant:
		return [puzzle_def, puzzle_node]

	var puzzle_def: PuzzleDef
	var puzzle_node: DotHopPuzzle


class Stats:
	signal analysis_complete(evt: Evt)

	func fire_analysis_complete(puzzle_def: PuzzleDef) -> void:
		Log.info("[Event]", "analysis complete", puzzle_def)
		analysis_complete.emit(Evt.new({puzzle_def=puzzle_def}))

class PuzzleNode:
	signal ready(evt: Evt)

	func fire_puzzle_node_ready(puzzle_node: DotHopPuzzle) -> void:
		ready.emit(Evt.new({puzzle_node=puzzle_node}))
