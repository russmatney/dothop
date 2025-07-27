extends Node
class_name GameSounds

## ready #####################################################################

func _ready() -> void:
	var puzzle_nodes: Array = get_tree().get_nodes_in_group(DHData.puzzle_group)
	for pnode: DotHopPuzzle in puzzle_nodes:
		setup_puzzle_node(pnode)
	Events.puzzle_node.ready.connect(func(evt: Events.Evt) -> void:
		setup_puzzle_node(evt.puzzle_node))

	# Should this differentiate which puzzle_node won? probably?
	Events.puzzle_node.win.connect(func(_evt: Events.Evt) -> void:
		# sound_on_win(evt.puzzle_node)
		sound_on_win())

func setup_puzzle_node(puzzle_node: DotHopPuzzle) -> void:
	if puzzle_node == null:
		Log.error("null puzzle_node passed?")
		return
	# note: do we want gameSounds supporting multiple puzzles at once?
	# note: we'll want world- or theme- based sounds at some point
	puzzle_node.player_moved.connect(sound_on_player_moved.bind(puzzle_node))
	puzzle_node.player_undo.connect(sound_on_player_undo)
	puzzle_node.move_rejected.connect(sound_on_move_rejected)
	puzzle_node.move_input_blocked.connect(sound_on_move_input_blocked)
	puzzle_node.rebuilt_nodes.connect(sound_on_rebuilt_nodes)

func sound_on_win() -> void:
	Sounds.play(Sounds.S.complete)

func sound_on_player_moved(puzzle_node: DotHopPuzzle) -> void:
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
