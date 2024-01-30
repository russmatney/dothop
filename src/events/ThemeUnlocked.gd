@tool
extends Event
class_name ThemeUnlocked

func get_theme() -> DotHopTheme:
	return Pandora.get_entity(get_string("theme_id")) as DotHopTheme

func data():
	var d = super.data()
	d.merge({theme=get_theme()})
	return d

static func new_event(theme: DotHopTheme):
	var event = Pandora.get_entity(EventIds.THEMEUNLOCKEDEVENT).instantiate()
	event.set_string("theme_id", theme.get_entity_id())
	event.set_event_data({
		display_name="%s unlocked" % theme.get_display_name(),
		})
	return event
