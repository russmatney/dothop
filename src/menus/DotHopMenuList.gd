@tool
extends NaviButtonList

var button_defs = [
	{
		label="Dino Menu",
		fn=Navi.nav_to_main_menu,
		hide_fn=func(): return not (OS.has_feature("dino") or OS.has_feature("editor")),
	},
]

var dh_game = "res://src/dotHop/DotHopGame.tscn"

func _ready():
	var ent = Pandora.get_entity(DhPuzzleSet.ONE)
	var puzzle_sets = Pandora.get_all_entities(Pandora.get_category(ent._category_id))

	for ps in puzzle_sets:
		add_menu_item({
			label=ps.get_display_name(),
			fn=func(): Navi.nav_to(dh_game, {setup=func(g): g.puzzle_set = ps}),
			})

	for def in button_defs:
		add_menu_item(def)

	if Engine.is_editor_hint():
		request_ready()