@tool
extends ButtonList

@onready var themes = Store.get_themes()

func _ready():
	for th in themes:
		add_menu_item({
			label=th.get_display_name(),
			fn=func():
			var game = get_tree().current_scene
			Log.pr("current_scene (game)", game)
			if game.name == "DotHopGame":
				game.change_theme(th)
				if get_tree().paused:
					Navi.resume()
			else:
				Log.warn("Current scene is not DotHopGame, cannot change theme", game)
			})
