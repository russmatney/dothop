extends Node
class_name TreadmillMode

## vars ###################################################################

@export var world: PuzzleWorld
@export var puzzle_num: int = 0

## ready #####################################################################

func _ready() -> void:
	var puzzle_nodes: Array = get_tree().get_nodes_in_group(DHData.puzzle_group)
	for pnode: DotHopPuzzle in puzzle_nodes:
		setup_puzzle_node(pnode)

	Events.puzzle_node.ready.connect(func(evt: Events.Evt) -> void:
		setup_puzzle_node(evt.puzzle_node))

	if world == null:
		Log.warn("No puzzle set, grabbing fallback from store")
		world = Store.get_worlds()[0]


## setup puzzle node #####################################################################

func setup_puzzle_node(puzzle_node: DotHopPuzzle) -> void:
	puzzle_node.win.connect(on_puzzle_win.bind(puzzle_node), CONNECT_ONE_SHOT)

## win #####################################################################

func on_puzzle_win(puzzle_node: DotHopPuzzle) -> void:
	Log.info("Puzzle complete! Rebuilding:", world.get_display_name(), "-", puzzle_num)
	DotHopPuzzle.rebuild_puzzle({puzzle_node=puzzle_node})
