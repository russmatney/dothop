extends Node
# autoload PuzzleStore

## vars #############################

@export var puzzle_sets: Array[PuzzleSetData]
var puzzles: Array[PuzzleDef]

func to_pretty() -> Variant:
	return {sets=puzzle_sets}

## ready #############################

func _ready() -> void:
	puzzles = []
	for psd in puzzle_sets:
		Log.pr("appending puzzles with psd", psd)
		puzzles.append_array(psd.puzzle_defs)

	Log.info({ready=self})

## get_puzzles #############################

func get_puzzles() -> Array[PuzzleDef]:
	return puzzles
