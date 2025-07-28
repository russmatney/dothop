extends CanvasLayer
class_name HUD

## vars ########################################################

@onready var puzzle_num_label: RichTextLabel = $%LevelNum
@onready var puzzle_message_label: RichTextLabel = $%LevelMessage
@onready var dots_remaining_label: RichTextLabel = $%DotsRemaining

@onready var undo_control_hint: BoxContainer = $%UndoControlHint
@onready var reset_control_hint: BoxContainer = $%ResetControlHint
@onready var undo_label: RichTextLabel = $%UndoLabel
@onready var reset_label: RichTextLabel = $%ResetLabel

@onready var undo_input_icon: ActionInputIcon = $%UndoInputIcon
@onready var reset_input_icon: ActionInputIcon = $%ResetInputIcon

@onready var undo_button: Button = $%UndoButton
@onready var reset_button: Button = $%ResetButton
@onready var pause_button: Button = $%PauseButton
@onready var shuffle_button: Button = $%ShuffleButton

@onready var action_button_list: VBoxContainer = $%ActionButtonList
@onready var key_input_hints: VBoxContainer = $%KeyInputHints

signal undo_pressed
signal reset_pressed
signal shuffle_pressed

var puzzle_def: PuzzleDef
var puzzle_node: DotHopPuzzle

## enter tree ###################################################################

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		get_tree().node_added.connect(on_node_added)

func on_node_added(node: Node) -> void:
	if node is DotHopPuzzle:
		setup_puzzle_node(node as DotHopPuzzle)

## ready #####################################################################

func _ready() -> void:
	for n: Variant in get_parent().get_children():
		if n is DotHopPuzzle:
			setup_puzzle_node(n as DotHopPuzzle)
			break

	set_control_icons()
	InputHelper.device_changed.connect(func(_device: String, _di: int) -> void: set_control_icons())
	InputHelper.joypad_changed.connect(func(_di: int, _connected: bool) -> void: set_control_icons())
	InputHelper.keyboard_input_changed.connect(func(_action: String, _event: InputEvent) -> void: set_control_icons())
	InputHelper.joypad_input_changed.connect(func(_action: String, _event: InputEvent) -> void: set_control_icons())

	reset_button.pressed.connect(func() -> void: reset_pressed.emit())
	undo_button.pressed.connect(func() -> void: undo_pressed.emit())
	pause_button.pressed.connect(DotHop.maybe_pause)
	shuffle_button.pressed.connect(func() -> void: shuffle_pressed.emit())

	if DotHop.is_mobile():
		# show the action button list
		action_button_list.show()
		key_input_hints.hide()
	else:
		# show the key input hints
		key_input_hints.show()
		action_button_list.hide()

func set_control_icons() -> void:
	undo_input_icon.set_icon_for_action("ui_undo")
	reset_input_icon.set_icon_for_action("restart")

func setup_puzzle_node(node: DotHopPuzzle) -> void:
	puzzle_node = node

	puzzle_node.ready.connect(update_hud)

	puzzle_node.player_moved.connect(func() -> void:
		update_hud()
		restart_fade_in_controls_tween())
	puzzle_node.player_undo.connect(func() -> void:
		update_hud()
		animate_undo()
		restart_fade_in_controls_tween())
	puzzle_node.move_rejected.connect(func() -> void:
		update_hud()
		show_controls(true)
		DotHop.notif("Move Rejected", {id="move_reaction"}))
	puzzle_node.move_input_blocked.connect(func() -> void:
		update_hud()
		DotHop.notif("Move Blocked", {id="move_reaction"}))
	puzzle_node.rebuilt_nodes.connect(func() -> void:
		update_hud()
		DotHop.notif("Puzzle Rebuilt", {id="puzzle_rebuilt"}))

	puzzle_node.ready.connect(func() -> void:
		reset_pressed.connect(puzzle_node.reset_pressed)
		undo_pressed.connect(puzzle_node.undo_pressed)
		shuffle_pressed.connect(puzzle_node.shuffle_pressed))

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


## unhandled_input ########################################################

func _unhandled_input(event: InputEvent) -> void:
	var is_restart_held: bool = Trolls.is_restart_held(event)
	var is_restart_released: bool = Trolls.is_restart_released(event)

	if is_restart_held:
		show_resetting()
	elif is_restart_released:
		hide_resetting()

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

## controls ########################################################

func controls() -> Array:
	var cts: Array = []
	if not resetting:
		cts.append(reset_control_hint)
	if not undoing:
		cts.append(undo_control_hint)
	return cts

var fade_controls_tween: Tween
func fade_controls() -> void:
	if fade_controls_tween != null and fade_controls_tween.is_running():
		return
	fade_controls_tween = create_tween()
	# wait a bit before fading
	fade_controls_tween.tween_interval(0.8)
	controls().map(func(c: CanvasItem) -> void:
		fade_controls_tween.parallel().tween_property(c, "modulate:a", 0.5, 0.8))

var show_controls_tween: Tween
func show_controls(force: bool = false) -> void:
	Log.pr("showing controls (force: ", force, ")")
	if show_controls_tween != null and show_controls_tween.is_running():
		show_controls_tween.kill()
		if not force:
			return
	show_controls_tween = create_tween()
	controls().map(func(c: CanvasItem) -> void:
		show_controls_tween.parallel().tween_property(c, "modulate:a", 1.0, 0.6))

# could probably just use a timer, but meh
var controls_tween: Tween
func restart_fade_in_controls_tween() -> void:
	fade_controls()
	if controls_tween != null:
		controls_tween.kill()
	controls_tween = create_tween()
	controls_tween.tween_callback(show_controls).set_delay(3.0)

## undoing ########################################################

var undoing: bool
var undo_tween: Tween
var undo_t: float = 0.3
func animate_undo() -> void:
	undoing = true

	undo_control_hint.set_pivot_offset(undo_control_hint.size/2)

	if undo_tween != null and undo_tween.is_running():
		return
	show_controls()
	undo_tween = create_tween()
	undo_tween.tween_property(undo_control_hint, "modulate:a", 1.0, undo_t/4)
	undo_tween.parallel().tween_property(undo_control_hint, "scale", Vector2.ONE*1.4, undo_t/2)
	undo_tween.tween_property(undo_control_hint, "scale", Vector2.ONE, undo_t/2)
	undo_tween.tween_callback(func() -> void: undoing = false)

## restarting ########################################################

var resetting: bool
var reset_tween: Tween
func show_resetting() -> void:
	var hold_t: float = DHData.reset_hold_t
	resetting = true
	reset_label.text = "Hold..."

	reset_control_hint.set_pivot_offset(reset_control_hint.size/2)

	if reset_tween != null and reset_tween.is_running():
		return
	reset_tween = create_tween()
	reset_tween.tween_property(reset_control_hint, "modulate:a", 1.0, hold_t/0.3)
	reset_tween.parallel().tween_property(reset_control_hint, "scale", 1.3 * Vector2.ONE, hold_t)
	# presumably we're back at the beginning
	reset_tween.tween_callback(hide_resetting)

func hide_resetting() -> void:
	resetting = false
	if reset_tween != null:
		reset_tween.kill()

	reset_label.text = "Reset"
	reset_control_hint.scale = Vector2.ONE
