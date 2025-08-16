@tool
extends Node
class_name ChoiceWarpMode


@export var enabled: bool = true
@export var delay: float = 0.4

func _ready() -> void:
	Events.puzzle_node.ready.connect(func(evt: Events.Evt) -> void:
		evt.puzzle_node.player_moved.connect(on_player_moved.bind(evt.puzzle_node)))

func on_player_moved(puzzle_node: DotHopPuzzle) -> void:
	if enabled:
		Log.info("Player moved in ChoiceWarpMode, triggering warp")

		# use puzzle state to test player moves
		# if there's only one for all directions, make that move

		var all_moves := puzzle_node.state.check_all_moves()
		Log.prn(all_moves)

		# decide if there's a choice or not
		# i.e. do we have multiple true moves to choose from
		# TODO clean up check_move's result and per-player logic
		var choices: Array[PuzzleState.Move] = []
		for moves: Array[PuzzleState.Move] in all_moves.values():
			# multi-hoppers complicating things again
			for mv: PuzzleState.Move in moves:
				# TODO skip if it's a move-to-goal when there are still dots left
				if mv.is_move():
					choices.append(mv)
					break

		if len(choices) == 1:
			U.call_in(self, func() -> void:
				Log.info("MAKING MOVE", choices[0])
				puzzle_node.move(choices[0].move_direction)
				, delay)
		elif len(choices) == 0:
			Log.info("Stuck?")
		else:
			Log.info("Ah, the next choice.")

	else:
		Log.info("ChoiceWarpMode is disabled, no warp performed")
