@tool
extends Node
# autoload ThemeStore

## vars #############################

@export var themes: Array[PuzzleThemeData]

func to_pretty() -> Variant:
	return {theme_count=len(themes)}

## ready #############################

func _ready() -> void:
	for _th in themes:
		# TODO check locked/unlocked?
		# validate some data?
		pass

	Log.info({theme_store_ready=self})

## get_puzzles #############################

func get_themes() -> Array[PuzzleThemeData]:
	return themes

func get_random_theme() -> PuzzleThemeData:
	return U.rand_of(themes)
