@tool
extends ButtonList

func _ready() -> void:
	var themes := ThemeStore.get_themes()
	for th in themes:
		add_menu_item({
			label=th.display_name,
			fn=Events.puzzle_node.fire_change_theme.bind(th),
			})
