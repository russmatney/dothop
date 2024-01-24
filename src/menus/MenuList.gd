@tool
extends ButtonList

var button_defs = [{
	nav_to="res://src/menus/worldmap/WorldMapMenu.tscn",
	label="Start",
	}, {
	nav_to="res://src/menus/OptionsPanel.tscn",
	label="Options",
	}, {
	label="Quit",
	fn=func(): get_tree().quit(),
	}]

# TODO is this used anywhere?
var dh_game = "res://src/puzzle/GameScene.tscn"

func _ready():
	for def in button_defs:
		add_menu_item(def)

	if Engine.is_editor_hint():
		request_ready()
