@tool
extends NaviButtonList

var button_defs = [
	{
		label="Resume",
		fn=Navi.resume,
	},
	{
		label="Controls",
		# TODO return from controls to whatever brought us here
		# TODO OR refactor into a popup panel
		fn=Navi.nav_to.bind("res://src/menus/ControlsPanel.tscn"),
	},
	{
		label="Main Menu",
		fn=Navi.nav_to_main_menu,
	},
]


func _ready():
	for def in button_defs:
		add_menu_item(def)

	if Engine.is_editor_hint():
		request_ready()
