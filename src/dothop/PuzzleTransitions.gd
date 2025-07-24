extends PuzzleNodeExtender
class_name PuzzleTransitions


func on_puzzle_node_ready(_node: DotHopPuzzle) -> void:
	puzzle_node.rebuilt_nodes.connect(func() -> void:
		Anim.puzzle_animate_intro_from_point(puzzle_node))
	# puzzle_node.ready.connect(func() -> void:
	# 	Anim.puzzle_animate_intro_from_point(puzzle_node))

func on_puzzle_node_exiting(_node: DotHopPuzzle) -> void:
	var outro_complete: Signal = Anim.puzzle_animate_outro_to_point(puzzle_node)
	await outro_complete
