extends Node
class_name RandomMode

## vars #####################################################################

@export var enabled: bool = true

## ready #####################################################################

func _ready() -> void:
	Events.puzzle_node.win.connect(func(evt: Events.Evt) -> void:
		build_random_puzzle(evt.puzzle_node))

## reset #####################################################################

func build_random_puzzle(puzzle_node: DotHopPuzzle) -> void:
	if enabled:
		Log.info("Resetting puzzle in Random mode.")

		var puzzle_def := PuzzleStore.get_random_puzzle()

		DotHopPuzzle.rebuild_puzzle({
			puzzle_node=puzzle_node,
			puzzle_def=puzzle_def,
			})
	else:
		Log.info("Random Mode is disabled, not resetting puzzle.")

## toggle #####################################################################

func enable() -> void:
	# TODO reset any 'win' puzzle nodes
	enabled = true

func disable() -> void:
	enabled = false
