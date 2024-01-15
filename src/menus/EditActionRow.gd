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

	Log.pr("\n\nicons for", action_name)
	Log.pr("kbd inputs", keyboard_inputs)
	for inp in keyboard_inputs:
		var icon = input_icon_scene.instantiate()
		var key_str_mods = OS.get_keycode_string(inp.get_keycode_with_modifiers())
		icon.input_text = key_str_mods
		# TODO if no action icon is found, we ought to remove the icon
		action_inputs.add_child(icon)

	Log.pr("joy inputs", joypad_inputs)


	# TODO pull controller icons for the given inputs
