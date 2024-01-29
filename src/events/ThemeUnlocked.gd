@tool
extends Event
class_name ThemeUnlocked

func get_theme() -> DotHopTheme:
	return get_resource("theme")

func data():
	var d = super.data()
	d.merge({theme=get_theme()})
	return d
