@tool
extends ButtonList

var button_defs = [
	{
		label="Resume",
		fn=Navi.resume,
	},
	{
		label="Main Menu",
		fn=Navi.nav_to_main_menu,
	},
]

func reload():
	for def in button_defs:
		add_menu_item(def)

func _ready():
	reload()

	if Engine.is_editor_hint():
		request_ready()
