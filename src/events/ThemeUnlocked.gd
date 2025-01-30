@tool
extends Event
class_name ThemeUnlocked

func get_theme() -> PuzzleTheme:
	return Pandora.get_entity(get_string("theme_id")) as PuzzleTheme

func data() -> Variant:
	var d: Dictionary = super.data()
	d.merge({theme=get_theme()})
	return d

static func new_event(theme: PuzzleTheme) -> ThemeUnlocked:
	var event: ThemeUnlocked = Pandora.get_entity(EventIds.THEMEUNLOCKEDEVENT).instantiate()
	event.set_string("theme_id", theme.get_entity_id())
	event.set_event_data({
		display_name="%s unlocked" % theme.get_display_name(),
		})
	return event
