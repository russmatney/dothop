extends Node
class_name PuzzleNodeExtender

## vars #####################################################################

var puzzle_node: DotHopPuzzle

## enter tree #####################################################################

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		get_tree().node_added.connect(on_node_added)

func on_node_added(node: Node) -> void:
	if node is DotHopPuzzle:
		_set_puzzle_node(node as DotHopPuzzle)

## ready #####################################################################

func _ready() -> void:
	# TODO clean up this search (use a group?)
	for n: Variant in get_parent().get_children():
		if n is DotHopPuzzle:
			_set_puzzle_node(n as DotHopPuzzle)
			break

	if puzzle_node == null:
		for n: Variant in get_children():
			if n is DotHopPuzzle:
				_set_puzzle_node(n as DotHopPuzzle)
				break

## setup puzzle node #####################################################################

func _set_puzzle_node(node: DotHopPuzzle) -> void:
	puzzle_node = node
	puzzle_node.tree_exiting.connect(func() -> void: on_puzzle_node_exiting(puzzle_node))

	# public function
	setup_puzzle_node(puzzle_node)

## public overrides #####################################################################

func setup_puzzle_node(_node: DotHopPuzzle) -> void:
	pass

func on_puzzle_node_exiting(_node: DotHopPuzzle) -> void:
	pass
