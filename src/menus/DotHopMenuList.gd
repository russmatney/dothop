@tool
extends NaviButtonList

var button_defs = []

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

	InputHelper.device_changed.connect(_on_input_device_changed)


func _on_input_device_changed(device: String, device_index: int) -> void:
	Log.pr("XBox? ", device == InputHelper.DEVICE_XBOX_CONTROLLER)
	Log.pr("Device index? ", device_index) # Probably 0
