extends Node
class_name TreadmillMode

## ready #####################################################################

func _ready() -> void:
	Events.puzzle_node.win.connect(func(evt: Events.Evt) -> void:
		Log.info("Treadmill detected a win! rebooting....")
		DotHopPuzzle.rebuild_puzzle({
			puzzle_node=evt.puzzle_node,
			}))
