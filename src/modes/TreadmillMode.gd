extends Node
class_name TreadmillMode

## vars #####################################################################

@export var enabled: bool = true

## ready #####################################################################

func _ready() -> void:
	Events.puzzle_node.win.connect(func(evt: Events.Evt) -> void:
		reset_puzzle(evt.puzzle_node))

## reset #####################################################################

func reset_puzzle(puzzle_node: DotHopPuzzle) -> void:
	if enabled:
		Log.info("Resetting puzzle in Treadmill mode.")
		DotHopPuzzle.rebuild_puzzle({puzzle_node=puzzle_node})
	else:
		Log.info("Treadmill is disabled, not resetting puzzle.")

## toggle #####################################################################

func enable() -> void:
	enabled = true
	Log.info("Treadmill enabled.")

func disable() -> void:
	enabled = false
	Log.info("Treadmill disabled.")
