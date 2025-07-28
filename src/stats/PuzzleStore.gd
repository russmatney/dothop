extends Node
# autoload PuzzleStore

## vars #############################

@export var puzzle_sets: Array[PuzzleSetData]
var puzzles: Array[PuzzleDef]

func to_pretty() -> Variant:
	return {sets=puzzle_sets, puzzles=len(puzzles)}

## ready #############################

func _ready() -> void:
	puzzles = []
	for psd in puzzle_sets:
		puzzles.append_array(psd.puzzle_defs)

	# Log.info({puzzle_store_ready=self})

## get_puzzles #############################

func get_puzzles() -> Array[PuzzleDef]:
	return puzzles
