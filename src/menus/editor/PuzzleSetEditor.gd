@tool
extends CanvasLayer

## vars ######################################################

var puzzle_sets: Array[PuzzleSet] = Store.get_puzzle_sets()

@onready var puzzle_set_grid = $%PuzzleSetGrid

## ready ######################################################

func _ready():
	render()

## render ######################################################

func render():
	for ps in puzzle_sets:
		Log.pr("rendering puzzle set", ps.get_display_name(), ps)
