@tool
extends ButtonList

@onready var themes := Store.get_themes()

func _ready() -> void:
	for th in themes:
		add_menu_item({
			label=th.get_display_name(),
			fn=Events.puzzle_node.fire_change_theme.bind(th.get_theme_data()),
			})
