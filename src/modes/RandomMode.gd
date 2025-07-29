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
		var theme_data := ThemeStore.get_random_theme()

		# TODO avoid repeating the current puzz/theme
		DotHopPuzzle.rebuild_puzzle({
			puzzle_node=puzzle_node,
			puzzle_def=puzzle_def,
			theme_data=theme_data,
			})
	else:
		Log.info("Random Mode is disabled, not resetting puzzle.")

## toggle #####################################################################

func enable() -> void:
	enabled = true
	Log.info("RandomMode enabled.")

func disable() -> void:
	enabled = false
	Log.info("RandomMode disabled.")
