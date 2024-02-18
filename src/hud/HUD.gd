extends CanvasLayer

## vars ########################################################

@onready var puzzle_num_label = $%LevelNum
@onready var puzzle_message_label = $%LevelMessage
@onready var dots_remaining_label = $%DotsRemaining

@onready var undo_control_hint = $%UndoControlHint
@onready var reset_control_hint = $%ResetControlHint
@onready var undo_label = $%UndoLabel
@onready var reset_label = $%ResetLabel
@onready var undo_input_icon = $%UndoInputIcon
@onready var reset_input_icon = $%ResetInputIcon


## ready ########################################################

func _ready():
	set_control_icons()
	InputHelper.device_changed.connect(func(_device, _di): set_control_icons())
	InputHelper.joypad_changed.connect(func(_di, _connected): set_control_icons())
	InputHelper.keyboard_input_changed.connect(func(_action, _event): set_control_icons())
	InputHelper.joypad_input_changed.connect(func(_action, _event): set_control_icons())

func set_control_icons():
	undo_input_icon.set_icon_for_action("ui_undo")
	reset_input_icon.set_icon_for_action("restart")

## unhandled_input ########################################################

func _unhandled_input(event):
	var is_undo = Trolls.is_undo(event)
	var is_move = Trolls.is_move(event)
	var is_restart_held = Trolls.is_restart_held(event)
	var is_restart_released = Trolls.is_restart_released(event)

	if is_undo:
		animate_undo()

	if is_move:
		restart_fade_in_controls_tween()

	if is_restart_held:
		show_resetting()
	elif is_restart_released:
		hide_resetting()

## update ########################################################

var last_puzzle_update

func update_state(data):
	last_puzzle_update = data

	update_puzzle_number(data)
	update_puzzle_message(data)
	update_dots_remaining(data)

## puzzle number ########################################################

func update_puzzle_number(entry):
	if "puzzle_number" in entry and "puzzle_number_total" in entry:
		puzzle_num_label.text = "[center]#%s/%s[/center]" %\
			[entry.puzzle_number, entry.puzzle_number_total]

## message ########################################################

func update_puzzle_message(entry):
	if "puzzle_message" in entry:
		puzzle_message_label.text = "[center]%s[/center]" % entry.puzzle_message

## dots remaining ########################################################

func update_dots_remaining(entry):
	if "dots_total" in entry:
		dots_remaining_label.text = "[center]%s dots left[/center]" % entry.dots_remaining

## controls ########################################################

func controls():
	var cts = []
	if not resetting:
		cts.append(reset_control_hint)
	if not undoing:
		cts.append(undo_control_hint)
	return cts

var fade_controls_tween
func fade_controls():
	if fade_controls_tween != null and fade_controls_tween.is_running():
		return
	fade_controls_tween = create_tween()
	# wait a bit before fading
	fade_controls_tween.tween_interval(0.8)
	controls().map(func(c):
		fade_controls_tween.parallel().tween_property(c, "modulate:a", 0.1, 0.8))

var show_controls_tween
func show_controls():
	if fade_controls_tween != null and fade_controls_tween.is_running():
		fade_controls_tween.kill()
		return
	show_controls_tween = create_tween()
	controls().map(func(c):
		show_controls_tween.parallel().tween_property(c, "modulate:a", 0.9, 0.6))

# could probably just use a timer, but meh
var controls_tween
func restart_fade_in_controls_tween():
	fade_controls()
	if controls_tween != null:
		controls_tween.kill()
	controls_tween = create_tween()
	controls_tween.tween_callback(show_controls).set_delay(3.0)

## undoing ########################################################

var undoing
var undo_tween
var undo_t = 0.3
func animate_undo():
	undoing = true
	if undo_tween != null and undo_tween.is_running():
		return
	show_controls()
	undo_tween = create_tween()
	undo_tween.tween_property(undo_control_hint, "modulate:a", 1.0, undo_t/4)
	undo_tween.parallel().tween_property(undo_control_hint, "scale", Vector2.ONE*1.4, undo_t/2)
	undo_tween.tween_property(undo_control_hint, "scale", Vector2.ONE, undo_t/2)
	undo_tween.tween_callback(func(): undoing = false)

## restarting ########################################################

var resetting
var reset_tween
func show_resetting():
	var hold_t = DHData.reset_hold_t
	resetting = true
	reset_label.text = "Hold..."

	if reset_tween != null and reset_tween.is_running():
		return
	reset_tween = create_tween()
	reset_tween.tween_property(reset_control_hint, "modulate:a", 1.0, hold_t/0.3)
	reset_tween.parallel().tween_property(reset_control_hint, "scale", 1.3 * Vector2.ONE, hold_t)
	# presumably we're back at the beginning
	reset_tween.tween_callback(hide_resetting)

func hide_resetting():
	resetting = false
	if reset_tween != null:
		reset_tween.kill()

	reset_label.text = "Reset:"
	reset_control_hint.scale = Vector2.ONE
