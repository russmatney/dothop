@tool
extends HBoxContainer

@export var action_name = "ui_accept"

@onready var action_name_label = $%ActionName
@onready var action_inputs = $%ActionInputs

var input_icon_scene = preload("res://src/menus/ActionInputIcon.tscn")

func _ready():
	action_name_label.text = "[center]%s[/center]" % action_name

	render_action_icons()

func render_action_icons():
	var keyboard_inputs = InputHelper.get_keyboard_inputs_for_action(action_name)
	var joypad_inputs = InputHelper.get_joypad_inputs_for_action(action_name)

	U.remove_children(action_inputs)
	# TODO if no action icon is found, we ought to remove the icon

	Log.pr("\n\nicons for", action_name)
	for inp in keyboard_inputs:
		var icon = input_icon_scene.instantiate()
		var key_str_mods = OS.get_keycode_string(inp.get_keycode_with_modifiers())
		icon.input_text = key_str_mods
		action_inputs.add_child(icon)

	Log.pr("joy inputs", joypad_inputs)
	for inp in joypad_inputs:
		var icon = input_icon_scene.instantiate()
		if "axis" in inp:
			icon.joy_axis = [inp.axis, inp.axis_value]
		else:
			var joy_button_idx = inp.button_index
			Log.pr("joy_button_idx", InputHelper.guess_device_name(), joy_button_idx)
			icon.joy_button = [InputHelper.guess_device_name(), inp.button_index]

		action_inputs.add_child(icon)
