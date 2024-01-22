@tool
extends ButtonList

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
	{
		label="Mute Music",
		hide_fn=func(): return DJ.muted_music,
		fn=func():
		DJ.toggle_mute_music(true)
		reload(),
	},
	{
		label="Unmute Music",
		hide_fn=func(): return not DJ.muted_music,
		fn=func():
		DJ.toggle_mute_music(false)
		reload(),
	},
	{
		label="Mute Sound",
		hide_fn=func(): return DJ.muted_sound,
		fn=func():
		DJ.toggle_mute_sound(true)
		reload(),
	},
	{
		label="Unmute Sound",
		hide_fn=func(): return not DJ.muted_sound,
		fn=func():
		DJ.toggle_mute_sound(false)
		reload(),
	},
	{
		label="Unmute All",
		hide_fn=func(): return not DJ.muted_sound or not DJ.muted_music,
		fn=func():
		DJ.mute_all(false)
		reload(),
	},
	{
		label="Mute All",
		hide_fn=func(): return DJ.muted_sound and DJ.muted_music,
		fn=func():
		DJ.mute_all(true)
		reload(),
	},
]

func reload():
	for def in button_defs:
		add_menu_item(def)

func _ready():
	reload()

	if Engine.is_editor_hint():
		request_ready()
