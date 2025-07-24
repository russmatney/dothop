extends PuzzleNodeExtender
class_name DotHopGame

## vars #####################################################################

@export var world: PuzzleWorld
@export var puzzle_num: int = 0

# TODO drop this
var already_complete: bool = false

## ready #####################################################################

func _ready() -> void:
	super._ready()

	DotHopPuzzle.rebuild_puzzle({container=self, world=world, puzzle_num=puzzle_num})

## input ###################################################################

func _unhandled_input(event: InputEvent) -> void:
	if not Engine.is_editor_hint() and Trolls.is_pause(event):
		DotHop.maybe_pause()

## load theme #####################################################################

# TODO this should be moved to a theme manager
func change_theme(theme: PuzzleTheme) -> void:
	var td := theme.get_theme_data()
	if puzzle_node.theme_data != td:
		DotHopPuzzle.rebuild_puzzle({theme_data=td, puzzle_node=puzzle_node})
