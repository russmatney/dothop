@tool
extends ButtonList

@onready var themes := Store.get_themes()

func _ready() -> void:
	for th in themes:
		add_menu_item({
			label=th.get_display_name(),
			fn=func() -> void:
			var game := get_tree().current_scene
			if game.name == "DotHopGame":
				@warning_ignore("unsafe_method_access")
				game.change_theme(th)
				if get_tree().paused:
					Navi.resume()
			else:
				Log.warn("Current scene is not DotHopGame, cannot change theme", game)
			})
