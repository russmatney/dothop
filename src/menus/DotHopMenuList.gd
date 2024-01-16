@tool
extends NaviButtonList

var button_defs = [{
	nav_to="res://src/menus/ControlsPanel.tscn",
	label="Controls",
	}]

var dh_game = "res://src/DotHopGame.tscn"

func _ready():
	var ent = Pandora.get_entity(PuzzleSetIDs.ONE)
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
