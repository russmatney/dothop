@tool
extends CanvasLayer

## vars ###############################################3

@onready var edit_action_scene = preload("res://src/menus/EditActionRow.tscn")
@onready var action_rows = $%EditActionRows
@onready var reset_controls_button = $%ResetControlsButton
@onready var main_menu_button = $%MainMenuButton
@onready var world_map_button = $%WorldMapButton
@onready var reset_save_data_button = $%ResetSaveDataButton

var displayed_actions = [
	"ui_accept", "ui_undo", "pause", "close", "restart",
	# "ui_up", "ui_down", "ui_left", "ui_right",
	]

## ready ###############################################3

func _ready():
	Log.pr("displayed actions", displayed_actions)

	render_action_rows()
	reset_controls_button.pressed.connect(on_reset_controls_pressed)

	# TODO "Are you sure" pop up, confirmation notification
	reset_save_data_button.pressed.connect(func():
		Store.reset_game_data())

	main_menu_button.pressed.connect(func():
		Navi.nav_to_main_menu())
	world_map_button.pressed.connect(func():
		Navi.nav_to("res://src/menus/worldmap/WorldMapMenu.tscn"))

## render ###############################################3

func render_action_rows():
	U.remove_children(action_rows)
	for action in displayed_actions:
		var row = edit_action_scene.instantiate()
		row.action_name = action
		action_rows.add_child(row)

	for row in action_rows.get_children():
		row.set_focus()
		break

## reset controls ###############################################3

func on_reset_controls_pressed():
	Log.pr("resetting controls!")
	InputHelper.reset_all_actions()
	render_action_rows()