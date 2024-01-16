@tool
extends CanvasLayer

## vars ###############################################3

@onready var edit_action_scene = preload("res://src/menus/EditActionRow.tscn")
@onready var action_rows = $%EditActionRows
@onready var reset_all_button = $%ResetButton

var displayed_actions = [
	"ui_accept", "ui_undo", "pause", "close", "restart",
	"ui_left", "ui_right", "ui_up", "ui_down"
	]

## ready ###############################################3

func _ready():
	Log.pr("displayed actions", displayed_actions)

	render_action_rows()
	reset_all_button.pressed.connect(on_reset_all_pressed)

## render ###############################################3

func render_action_rows():
	U.remove_children(action_rows)
	for action in displayed_actions:
		var row = edit_action_scene.instantiate()
		row.action_name = action
		action_rows.add_child(row)

## reset all ###############################################3

func on_reset_all_pressed():
	Log.pr("resetting all actions!")
	InputHelper.reset_all_actions()
	render_action_rows()
