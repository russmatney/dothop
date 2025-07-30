@tool
extends Node
class_name PuzzleGym

## vars #####################################################################

enum Mode {Treadmill, Random}

var puzzle_def: PuzzleDef

@onready var puzzle_node: DotHopPuzzle

@onready var treadmill_mode_button: Button = $%TreadmillModeButton
@onready var random_mode_button: Button = $%RandomModeButton

@onready var treadmill_mode: TreadmillMode = $%TreadmillMode
@onready var random_mode: RandomMode = $%RandomMode

@onready var new_puzzle_button: Button = $%NewPuzzleButton

@onready var puzzle_def_label: RichTextLabel = $%PuzzleDefLabel
@onready var puzzle_def_difficulty: RichTextLabel = $%PuzzleDefDifficulty

## ready #####################################################################

func _ready() -> void:
	Events.puzzle_node.ready.connect(func(evt: Events.Evt) -> void:
		puzzle_node = evt.puzzle_node
		puzzle_def = puzzle_node.puzzle_def

		puzzle_def_label.text = "[center]%s" % puzzle_def.get_label()
		if puzzle_def.idx <= 3:
			puzzle_def_difficulty.text = "[center]easy"
		elif puzzle_def.idx <= 7:
			puzzle_def_difficulty.text = "[center]med"
		else:
			puzzle_def_difficulty.text = "[center]hard"
		)

	puzzle_def = PuzzleStore.get_random_puzzle()
	DotHopPuzzle.rebuild_puzzle({container=self, puzzle_def=puzzle_def})

	treadmill_mode_button.pressed.connect(enable_treadmill_mode)
	random_mode_button.pressed.connect(enable_random_mode)

	new_puzzle_button.pressed.connect(func() -> void:
		puzzle_def = PuzzleStore.get_random_puzzle()
		DotHopPuzzle.rebuild_puzzle({
			puzzle_node=puzzle_node,
			puzzle_def=puzzle_def,
			}))

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
	DotHop.notif("[Treadmill Mode]")

func enable_random_mode() -> void:
	stop_all_modes()
	random_mode.enable()
	random_mode_button.set_disabled(true)
	DotHop.notif("[Random Mode]")
