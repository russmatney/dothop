extends Node
class_name PuzzleTransitions

func _ready() -> void:
	var puzzle_nodes: Array = get_tree().get_nodes_in_group(DHData.puzzle_group)
	for pnode: DotHopPuzzle in puzzle_nodes:
		setup_puzzle_node(pnode)

	Events.puzzle_node.ready.connect(func(evt: Events.Evt) -> void:
		setup_puzzle_node(evt.puzzle_node)
		on_puzzle_node_ready(evt.puzzle_node))

func on_puzzle_node_ready(puzzle_node: DotHopPuzzle) -> void:
	Anim.puzzle_animate_intro_from_point(puzzle_node)

func setup_puzzle_node(puzzle_node: DotHopPuzzle) -> void:
	puzzle_node.rebuilt_nodes.connect(func() -> void:
		Anim.puzzle_animate_intro_from_point(puzzle_node))

	# is it possible to await an event instead?
	puzzle_node.add_pre_remove_hook(animate_exit.bind(puzzle_node))

func animate_exit(puzzle_node: DotHopPuzzle) -> Signal:
	var outro_complete: Signal = Anim.puzzle_animate_outro_to_point(puzzle_node)
	return outro_complete
