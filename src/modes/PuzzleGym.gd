@tool
extends Node
class_name PuzzleGym

## vars #####################################################################

enum Mode {Treadmill, Random}

@export var puzzle_set_data: PuzzleSetData
@export var puzzle_def: PuzzleDef
@export var theme_data: PuzzleThemeData

@onready var puzzle_node: DotHopPuzzle

@onready var treadmill_mode_button: Button = $%TreadmillModeButton
@onready var random_mode_button: Button = $%RandomModeButton

@onready var treadmill_mode: TreadmillMode = $%TreadmillMode
@onready var random_mode: RandomMode = $%RandomMode

## ready #####################################################################

func _ready() -> void:
	Events.puzzle_node.ready.connect(func(evt: Events.Evt) -> void:
		puzzle_node = evt.puzzle_node)

	if puzzle_def == null:
		puzzle_def = PuzzleStore.get_puzzles()[0]

	DotHopPuzzle.rebuild_puzzle({container=self, puzzle_def=puzzle_def, theme_data=theme_data})

	treadmill_mode_button.pressed.connect(enable_treadmill_mode)
	random_mode_button.pressed.connect(enable_random_mode)

	# force an initial mode
	enable_random_mode()

## mode toggles #####################################################################

# yeesh, could use a cheap state machine lib
func stop_all_modes() -> void:
	treadmill_mode_button.set_disabled(false)
	random_mode_button.set_disabled(false)

	treadmill_mode.disable()
	random_mode.disable()

func enable_treadmill_mode() -> void:
	stop_all_modes()
	treadmill_mode.enable()
	treadmill_mode_button.set_disabled(true)

func enable_random_mode() -> void:
	stop_all_modes()
	random_mode.enable()
	random_mode_button.set_disabled(true)
