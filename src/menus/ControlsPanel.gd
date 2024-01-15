@tool
extends CanvasLayer

@onready var edit_action_scene = preload("res://src/menus/EditActionRow.tscn")

@onready var action_rows = $%EditActionRows

var displayed_actions = [
	"ui_accept", "ui_undo", "pause", "close", "restart",
	"ui_left", "ui_right", "ui_up", "ui_down"
	]

func _ready():
	Log.pr("displayed actions", displayed_actions)

	render_action_rows()

func render_action_rows():
	U.remove_children(action_rows)
	for action in displayed_actions:
		var row = edit_action_scene.instantiate()
		row.action_name = action
		action_rows.add_child(row)
