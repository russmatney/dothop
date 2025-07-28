@tool
extends Node
# autoload Events

var stats := Stats.new()
var puzzle_node := PuzzleNode.new()

class Evt:
	func _init(opts: Dictionary) -> void:
		puzzle_def = opts.get("puzzle_def")
		puzzle_node = opts.get("puzzle_node")
		theme_data = opts.get("theme_data")
		# Log.info("new event", self)

	func to_pretty() -> Variant:
		return [puzzle_def, puzzle_node, theme_data]

	var puzzle_def: PuzzleDef
	var puzzle_node: DotHopPuzzle
	var theme_data: PuzzleThemeData


class Stats:
	signal analysis_complete(evt: Evt)

	func fire_analysis_complete(puzzle_def: PuzzleDef) -> void:
		Log.info("[Event]", "analysis complete", puzzle_def)
		analysis_complete.emit(Evt.new({puzzle_def=puzzle_def}))

class PuzzleNode:
	signal ready(evt: Evt)
	signal exiting(evt: Evt)
	# signal pre_remove_hook(evt: Evt)
	signal change_theme(evt: Evt)
	signal win(evt: Evt)

	func fire_puzzle_node_ready(puzzle_node: DotHopPuzzle) -> void:
		ready.emit(Evt.new({puzzle_node=puzzle_node}))

	func fire_puzzle_node_exiting(puzzle_node: DotHopPuzzle) -> void:
		exiting.emit(Evt.new({puzzle_node=puzzle_node}))

	# is it possible to await a signal like this?
	# func fire_puzzle_node_pre_remove_hook(puzzle_node: DotHopPuzzle) -> void:
	# 	pre_remove_hook.emit(Evt.new({puzzle_node=puzzle_node}))

	func fire_change_theme(theme: PuzzleThemeData) -> void:
		change_theme.emit(Evt.new({theme_data=theme}))

	func fire_win(puzzle_node: DotHopPuzzle) -> void:
		Log.info("[Event] PuzzleNode win!")
		win.emit(Evt.new({puzzle_node=puzzle_node}))
