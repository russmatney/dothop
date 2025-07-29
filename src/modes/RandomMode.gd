extends Node
class_name RandomMode

## vars #####################################################################

@export var enabled: bool = true

@onready var new_puzzle_button: Button = $%NewPuzzleButton

## ready #####################################################################

func _ready() -> void:
	Events.puzzle_node.win.connect(func(evt: Events.Evt) -> void:
		build_random_puzzle(evt.puzzle_node))

	if new_puzzle_button:
		new_puzzle_button.pressed.connect(func() -> void:
			build_random_puzzle(Events.puzzle_node.get_current()))

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
	enabled = true
	enable_children()
	Log.info("RandomMode enabled.")

func disable() -> void:
	enabled = false
	disable_children()
	Log.info("RandomMode disabled.")

func enable_children() -> void:
	for ch: Node in get_children():
		if ch is CanvasLayer:
			(ch as CanvasLayer).set_visible(true)

func disable_children() -> void:
	for ch: Node in get_children():
		if ch is CanvasLayer:
			(ch as CanvasLayer).set_visible(false)
