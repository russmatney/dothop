@tool
extends ButtonList

var button_defs = [{
	nav_to="res://src/menus/worldmap/WorldMapMenu.tscn",
	label="Start",
	}, {
	nav_to="res://src/menus/ControlsPanel.tscn",
	label="Controls",
	}]

# TODO is this used anywhere?
var dh_game = "res://src/puzzle/GameScene.tscn"

func _ready():
	for def in button_defs:
		add_menu_item(def)

	if Engine.is_editor_hint():
		request_ready()
