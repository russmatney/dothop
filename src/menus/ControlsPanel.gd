@tool
extends CanvasLayer

@onready var edit_action_scene = preload("res://src/menus/EditActionRow.tscn")

@onready var action_rows = $%EditActionRows

# TODO list all relevant dothop actions
var displayed_actions = ["ui_accept", "ui_undo", "ui_redo"]

func _ready():
	Log.pr("displayed actions", displayed_actions)

	# TODO create edit_action scenes
