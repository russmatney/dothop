extends CanvasLayer
class_name HUD

## vars ########################################################

@onready var puzzle_num_label: RichTextLabel = $%LevelNum
@onready var puzzle_message_label: RichTextLabel = $%LevelMessage
@onready var dots_remaining_label: RichTextLabel = $%DotsRemaining

var puzzle_def: PuzzleDef
var puzzle_node: DotHopPuzzle

## ready #####################################################################

func _ready() -> void:
	Events.puzzle_node.ready.connect(func(evt: Events.Evt) -> void:
		setup_puzzle_node(evt.puzzle_node))

func setup_puzzle_node(node: DotHopPuzzle) -> void:
	puzzle_node = node

	puzzle_node.ready.connect(update_hud)
	puzzle_node.player_moved.connect(update_hud)
	puzzle_node.player_undo.connect(update_hud)
	puzzle_node.move_rejected.connect(update_hud)
	puzzle_node.move_input_blocked.connect(update_hud)
	puzzle_node.rebuilt_nodes.connect(update_hud)

	puzzle_node.move_rejected.connect(func() -> void:
		DotHop.notif("Move Rejected", {id="move_reaction"}))
	puzzle_node.move_input_blocked.connect(func() -> void:
		DotHop.notif("Move Blocked", {id="move_reaction"}))
	puzzle_node.rebuilt_nodes.connect(func() -> void:
		DotHop.notif("Puzzle Rebuilt", {id="puzzle_rebuilt"}))

## update hud #####################################################################

func update_hud() -> void:
	if puzzle_node and puzzle_node.world:
		var rem: int = len(puzzle_node.world.get_puzzles().filter(func(p: PuzzleDef) -> bool:
			return not p.is_completed))
		var data: Dictionary = {
			puzzle_def=puzzle_node.puzzle_def,
			puzzles_remaining=rem,
			dots_total=puzzle_node.state.dot_count(),
			dots_remaining=puzzle_node.state.dot_count(true),
			}
		update_state(data)

## update ########################################################

var last_puzzle_update: Dictionary

func update_state(data: Dictionary) -> void:
	last_puzzle_update = data

	puzzle_def = data.puzzle_def
	update_puzzle_number(data)
	update_puzzle_message()
	update_dots_remaining(data)

## puzzle number ########################################################

func update_puzzle_number(entry: Dictionary) -> void:
	if "puzzles_remaining" in entry:
		var rem: int = entry.puzzles_remaining
		if rem == 0:
			puzzle_num_label.text = "[center]Puzzle set complete![/center]"
		elif rem == 1:
			puzzle_num_label.text = "[center]Last puzzle![/center]"
		else:
			puzzle_num_label.text = "[center]%s puzzles left[/center]" % entry.puzzles_remaining

## message ########################################################

func update_puzzle_message() -> void:
	if puzzle_def.get_message():
		puzzle_message_label.text = "[center]%s[/center]" % puzzle_def.get_message()

## dots remaining ########################################################

func update_dots_remaining(entry: Dictionary) -> void:
	if "dots_total" in entry:
		dots_remaining_label.text = "[center]%s dots left[/center]" % entry.dots_remaining
