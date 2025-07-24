extends Node
class_name GameSounds

## vars #####################################################################

var puzzle_node: DotHopPuzzle

## enter tree #####################################################################

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		get_tree().node_added.connect(on_node_added)

func on_node_added(node: Node) -> void:
	if node is DotHopPuzzle:
		setup_puzzle_node(node as DotHopPuzzle)

## ready #####################################################################

func _ready() -> void:
	# TODO maybe want a broader search than this
	for n: Variant in get_parent().get_children():
		if n is DotHopPuzzle:
			setup_puzzle_node(n as DotHopPuzzle)
			break

## ready #####################################################################

func setup_puzzle_node(node: DotHopPuzzle) -> void:
	# note: do we want gameSounds supporting multiple puzzles at once?
	# note: we'll want world- or theme- based sounds at some point
	puzzle_node = node

	puzzle_node.win.connect(sound_on_win)
	puzzle_node.player_moved.connect(sound_on_player_moved)
	puzzle_node.player_undo.connect(sound_on_player_undo)
	puzzle_node.move_rejected.connect(sound_on_move_rejected)
	puzzle_node.move_input_blocked.connect(sound_on_move_input_blocked)
	puzzle_node.rebuilt_nodes.connect(sound_on_rebuilt_nodes)

func sound_on_win() -> void:
	Sounds.play(Sounds.S.complete)

func sound_on_player_moved() -> void:
	var total_dots: float = float(puzzle_node.state.dot_count() + 1)
	var dotted: float = total_dots - float(puzzle_node.state.dot_count(true)) - 1
	# ensure some minimum
	dotted = clamp(dotted, total_dots/4, total_dots)
	if puzzle_node.state.win:
		dotted += 1
	Sounds.play(Sounds.S.dot_collected, {scale_range=total_dots, scale_note=dotted, interrupt=true})

func sound_on_player_undo() -> void:
	Sounds.play(Sounds.S.minimize)

func sound_on_move_rejected() -> void:
	Sounds.play(Sounds.S.showjumbotron)

func sound_on_move_input_blocked() -> void:
	pass

func sound_on_rebuilt_nodes() -> void:
	Sounds.play(Sounds.S.maximize)
