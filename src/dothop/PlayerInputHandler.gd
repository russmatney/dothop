extends Node
class_name PlayerInputHandler

# for now, only supports one node at a time
var puzzle_node: DotHopPuzzle

var reset_tween: Tween

var enabled: bool = true

## ready ##############################################################

func _ready() -> void:
	var puzzles := get_tree().get_nodes_in_group(DHData.puzzle_group)
	for pnode: DotHopPuzzle in puzzles:
		setup_puzzle_node(pnode)

	Events.puzzle_node.ready.connect(func(evt: Events.Evt) -> void:
		setup_puzzle_node(evt.puzzle_node))

func setup_puzzle_node(pnode: DotHopPuzzle) -> void:
	puzzle_node = pnode

func disable() -> void:
	enabled = false

func enable() -> void:
	enabled = true

## input ##############################################################

var just_logged_blocked_input: bool = false
func _unhandled_input(event: InputEvent) -> void:
	if not enabled or puzzle_node == null:
		return

	if puzzle_node.state != null and puzzle_node.state.win:
		if not just_logged_blocked_input:
			Log.info("Blocking input events b/c we're in a win state")
			just_logged_blocked_input = true
		return
	just_logged_blocked_input = false

	if Trolls.is_move(event):
		if puzzle_node.state == null:
			Log.warn("No state, ignoring move input")
			return
		var move_dir: Vector2 = Trolls.grid_move_vector(event)
		puzzle_node.attempt_move(move_dir)
	elif Trolls.is_undo(event) and not puzzle_node.block_move_input:
		if puzzle_node.state == null:
			Log.warn("No state, ignoring undo input")
			return
		puzzle_node.undo_last_move()
		puzzle_node.restart_block_move_timer(0.1)

	elif Trolls.is_restart_held(event):
		hold_to_reset_puzzle()
	elif Trolls.is_restart_released(event):
		cancel_reset_puzzle()
	elif Trolls.is_shuffle(event):
		puzzle_node.shuffle_pressed()


## reset_tween ##############################################################

func hold_to_reset_puzzle() -> void:
	if reset_tween != null and reset_tween.is_running():
		# already holding
		return
	reset_tween = create_tween()
	reset_tween.tween_callback(func() -> void:
		if puzzle_node:
			puzzle_node.reset_pressed())\
		.set_delay(DHData.reset_hold_t)

func cancel_reset_puzzle() -> void:
	if reset_tween == null:
		return
	reset_tween.kill()
