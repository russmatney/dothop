@tool
extends PanelContainer

## vars ###############################################3

@onready var edit_action_scene := preload("res://src/menus/controls/EditActionRow.tscn")
@onready var action_rows: BoxContainer = $%EditActionRows
@onready var reset_controls_button: Button = $%ResetControlsButton

@onready var mobile_controls_message: RichTextLabel = $%MobileControlsMessage
@onready var scroll_container: ScrollContainer = $%ScrollContainer

var displayed_actions := [
	"ui_accept", "ui_undo", "pause", "close", "restart",
	# "ui_up", "ui_down", "ui_left", "ui_right",
	]

## ready ###############################################3

func _ready() -> void:
	if DotHop.is_mobile():
		mobile_controls_message.show()
		scroll_container.hide()
	else:
		mobile_controls_message.hide()
		scroll_container.show()

		render_action_rows()
	reset_controls_button.pressed.connect(on_reset_controls_pressed)

## render ###############################################3

func render_action_rows() -> void:
	U.remove_children(action_rows)
	for action: String in displayed_actions:
		var row: EditActionRow = edit_action_scene.instantiate()
		row.edit_pressed.connect(on_edit_pressed.bind(row))
		row.action_name = action
		action_rows.add_child(row)

	for row: EditActionRow in action_rows.get_children():
		row.set_focus()
		break

## on edit

func on_edit_pressed(row: EditActionRow) -> void:
	for r: EditActionRow in action_rows.get_children():
		if r != row:
			r.clear_editing_unless(row)

## reset controls ###############################################3

func on_reset_controls_pressed() -> void:
	Log.info("resetting controls!")
	InputHelper.reset_all_actions()
	render_action_rows()
