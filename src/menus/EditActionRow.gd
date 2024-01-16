@tool
extends HBoxContainer

## vars ###############################################3

@export var action_name = "ui_accept"

@onready var action_name_label = $%ActionName
@onready var action_inputs = $%ActionInputs

@onready var edit_button = $%EditButton

var input_icon_scene = preload("res://src/menus/ActionInputIcon.tscn")

var waiting_for_new_input = false
var current_key_input
var current_joy_input

## ready ###############################################3

func _ready():
	action_name_label.text = "[center]%s[/center]" % action_name
	render_action_icons()
	edit_button.pressed.connect(on_edit_pressed)

## grab_focus ###############################################3

func set_focus():
	edit_button.grab_focus()

## render action icons ###############################################3

func render_action_icons():
	var keyboard_inputs = InputHelper.get_keyboard_inputs_for_action(action_name)
	var joypad_inputs = InputHelper.get_joypad_inputs_for_action(action_name)

	U.remove_children(action_inputs)
	# TODO if no action icon is found, we ought to remove the icon

	for inp in keyboard_inputs:
		if not current_key_input:
			current_key_input = inp
		var icon = input_icon_scene.instantiate()
		var key_str_mods = OS.get_keycode_string(inp.get_keycode_with_modifiers())
		icon.input_text = key_str_mods
		action_inputs.add_child(icon)

	for inp in joypad_inputs:
		var icon = input_icon_scene.instantiate()
		if "axis" in inp:
			icon.joy_axis = [inp.axis, inp.axis_value]
		else:
			if not current_joy_input:
				current_joy_input = inp
			icon.joy_button = [InputHelper.guess_device_name(), inp.button_index]

		action_inputs.add_child(icon)

## edit signals ###############################################3

func on_edit_pressed():
	waiting_for_new_input = true
	Log.pr("edit pressed, waiting for input!", action_name)
	edit_button.text = "...listening for new key..."

## listening for new key ###############################################3

func _unhandled_input(event) -> void:
	if not waiting_for_new_input: return

	var accepted = false
	if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
		accept_event()
		InputHelper.replace_keyboard_input_for_action(action_name, current_key_input, event, true)
		accepted = true

	if event is InputEventJoypadButton and event.is_pressed():
		accept_event()
		InputHelper.replace_joypad_input_for_action(action_name, current_joy_input, event, true)
		accepted = true

	if accepted:
		render_action_icons()
		edit_button.text = "Edit"
		waiting_for_new_input = false
