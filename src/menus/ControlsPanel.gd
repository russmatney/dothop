@tool
extends CanvasLayer

@onready var edit_action_scene = preload("res://src/menus/EditActionRow.tscn")

@onready var action_rows = $%EditActionRows

# TODO list all relevant dothop actions
var displayed_actions = ["ui_accept", "ui_undo", "ui_redo"]

func _ready():
	Log.pr("displayed actions", displayed_actions)

	render_action_rows()

func render_action_rows():
	U.remove_children(action_rows)
	for action in displayed_actions:
		var row = edit_action_scene.instantiate()
		row.action_name = action
		action_rows.add_child(row)
