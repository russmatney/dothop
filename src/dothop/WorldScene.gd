extends Node
class_name WorldScene

## vars #####################################################################

@export var world: PuzzleWorld
@export var puzzle_num: int = 0

## ready #####################################################################

func _ready() -> void:
	DotHopPuzzle.rebuild_puzzle({container=self, world=world, puzzle_num=puzzle_num})
