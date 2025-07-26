extends Node
class_name DotHopGame

## vars #####################################################################

@export var world: PuzzleWorld
@export var puzzle_num: int = 0

## ready #####################################################################

func _ready() -> void:
	DotHopPuzzle.rebuild_puzzle({container=self, world=world, puzzle_num=puzzle_num})

## input ###################################################################

func _unhandled_input(event: InputEvent) -> void:
	if not Engine.is_editor_hint() and Trolls.is_pause(event):
		DotHop.maybe_pause()
