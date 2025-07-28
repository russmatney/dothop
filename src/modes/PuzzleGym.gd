@tool
extends Node
class_name PuzzleGym

## vars #####################################################################

@export var puzzle_set_data: PuzzleSetData
@export var puzzle_def: PuzzleDef
@export var theme_data: PuzzleThemeData

@onready var puzzle_node: DotHopPuzzle

## ready #####################################################################

func _ready() -> void:
	Events.puzzle_node.ready.connect(func(evt: Events.Evt) -> void:
		puzzle_node = evt.puzzle_node)

	if puzzle_def == null:
		puzzle_def = PuzzleStore.get_puzzles()[0]

	DotHopPuzzle.rebuild_puzzle({container=self, puzzle_def=puzzle_def, theme_data=theme_data})
