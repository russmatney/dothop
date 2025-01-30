@tool
extends ButtonList

var button_defs: Array = [{
	nav_to="res://src/menus/MainMenu.tscn",
	label="< Main Menu",
	}]

func _ready() -> void:
	for def: Dictionary in button_defs:
		add_menu_item(def)

	if Engine.is_editor_hint():
		request_ready()
