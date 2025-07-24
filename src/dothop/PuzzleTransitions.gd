extends PuzzleNodeExtender
class_name PuzzleTransitions


func setup_puzzle_node() -> void:
	puzzle_node.add_pre_remove_hook(animate_exit)

	puzzle_node.ready.connect(func() -> void:
		Anim.puzzle_animate_intro_from_point(puzzle_node))
	puzzle_node.rebuilt_nodes.connect(func() -> void:
		Anim.puzzle_animate_intro_from_point(puzzle_node))

func animate_exit() -> Signal:
	var outro_complete: Signal = Anim.puzzle_animate_outro_to_point(puzzle_node)
	return outro_complete
