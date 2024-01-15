extends HBoxContainer

@export var action_name = "ui_accept"

@onready var action_name_label = $%ActionName
@onready var action_name_inputs = $%ActionInputs

func _ready():
	print("edit action row ready", action_name)

	render_action_icons()

func render_action_icons():
	var keyboard_inputs = InputHelper.get_keyboard_inputs_for_action(action_name)
	var joypad_inputs = InputHelper.get_joypad_inputs_for_action(action_name)

	Log.pr("kbd inputs", keyboard_inputs)
	Log.pr("joy inputs", joypad_inputs)

	# TODO pull controller icons for the given inputs
