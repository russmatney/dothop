@tool
extends NaviButtonList

var button_defs = [{
	nav_to="res://src/menus/ControlsPanel.tscn",
	label="Controls",
	}, {
	nav_to="res://src/menus/MainMenu.tscn",
	label="Main Menu",
	}]

func _ready():
	for def in button_defs:
		add_menu_item(def)

	if Engine.is_editor_hint():
		request_ready()
