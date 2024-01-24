@tool
extends ButtonList

var button_defs = []

var dh_game = "res://src/puzzle/GameScene.tscn"

func _ready():
	for ps in Store.get_puzzle_sets():
		add_menu_item({
			label=ps.get_display_name(),
			puzzle_set=ps,
			fn=func(): Navi.nav_to(dh_game, {setup=func(g): g.puzzle_set = ps}),
			is_disabled=func(): return not ps.is_unlocked(),
			})

	for def in button_defs:
		add_menu_item(def)

	if Engine.is_editor_hint():
		request_ready()
