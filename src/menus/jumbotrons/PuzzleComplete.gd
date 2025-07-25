@tool
extends Jumbotron
class_name PuzzleComplete

## vars ############################################################

@onready var puzzle_progress_panel: PuzzleProgressPanel = $%PuzzleProgressPanel
var world: PuzzleWorld
var start_puzzle_num: int
var end_puzzle_num: int

## ready ############################################################

func _ready() -> void:
	super._ready()
	render()

## build puzzle list ############################################################

func render() -> void:
	if not world:
		# world = Store.get_worlds()[0]
		Log.warn("No puzzle set found on PuzzleComplete scene")
	else:
		puzzle_progress_panel.render({
			world=world,
			start_puzzle_num=start_puzzle_num,
			end_puzzle_num=end_puzzle_num,
			})

	var delay: float = 0.3
	for node: CanvasItem in [header, body]:
		node.modulate.a = 0
		Anim.fade_in(node, 1.0, delay)
		delay += 0.9
