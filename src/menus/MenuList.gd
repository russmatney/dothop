@tool
extends NaviButtonList

var button_defs = [{
	nav_to="res://src/menus/WorldMap.tscn",
	label="Start",
	}, {
	nav_to="res://src/menus/ControlsPanel.tscn",
	label="Controls",
	}]

var dh_game = "res://src/DotHopGame.tscn"

func _ready():
	for def in button_defs:
		add_menu_item(def)

	if Engine.is_editor_hint():
		request_ready()
