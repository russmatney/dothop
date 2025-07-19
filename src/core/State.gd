@tool
extends Object
class_name GameState

var worlds: Array[PuzzleWorld] = []
var themes: Array[PuzzleTheme] = []

## new #######################################################

func _init(events: Array = []) -> void:
	worlds = initial_worlds()
	themes = initial_themes()
	apply_events(events)
	attach_gameplay_data()

## apply events #######################################################

func apply_events(events: Array) -> void:
	Log.info("applying %s events, including (skipping puzzle-complete events)" % len(events),
		events\
		.filter(func(ev: Variant) -> bool:
			return not ev is PuzzleCompleted
			)\
		.map(func(e: Variant) -> String:
			if e == null: return "Null Event"
			return (e as Event).get_display_name()))

	for event: Event in events:
		apply_event(event)

func apply_event(event: Event) -> void:
	if event is WorldCompleted:
		var world: PuzzleWorld = find_world((event as WorldCompleted).get_world())
		if not world:
			Log.warn("Could not apply event! No world found.", event)
		world.mark_complete()
	elif event is PuzzleCompleted:
		var world: PuzzleWorld = find_world((event as PuzzleCompleted).get_world())
		if not world:
			Log.warn("Could not apply event! No world found.", event)
		world.mark_puzzle_complete((event as PuzzleCompleted).get_puzzle_index())
		world.update_max_index((event as PuzzleCompleted).get_puzzle_index())
	elif event is PuzzleSkipped:
		var world: PuzzleWorld = find_world((event as PuzzleSkipped).get_world())
		if not world:
			Log.warn("Could not apply event! No world found.", event)
		if (event as PuzzleSkipped).is_active():
			world.mark_puzzle_skipped((event as PuzzleSkipped).get_puzzle_index())
		else:
			world.mark_puzzle_not_skipped((event as PuzzleSkipped).get_puzzle_index())
	elif event is WorldUnlocked:
		var world: PuzzleWorld = find_world((event as WorldUnlocked).get_world())
		if not world:
			Log.warn("Could not apply event! No world found.", event)
		world.unlock()
	elif event is ThemeUnlocked:
		var th: PuzzleTheme = find_theme((event as ThemeUnlocked).get_theme())
		if not th:
			Log.warn("Could not apply event! No theme found.", event)
		th.unlock()
	else:
		Log.warn("Could not apply unhandled event", event)

## initial states #######################################################

func initial_worlds() -> Array[PuzzleWorld]:
	var ent: PuzzleWorld = Pandora.get_entity(PuzzleWorldIDs.THEMDOTS)
	if ent == null:
		Log.warn("no THEMDOTS PuzzleWorld entity found. Is Pandora data loaded?")
		return []
	var pss: Array = Pandora.get_all_entities(Pandora.get_category(ent._category_id))\
		.map(func(e: PandoraEntity) -> PuzzleWorld: return e.instantiate())
	var ws: Array[PuzzleWorld] = []
	ws.assign(pss)
	ws.sort_custom(func(a: PuzzleWorld, b: PuzzleWorld) -> bool: return a.get_sort_order() < b.get_sort_order())
	return ws

func initial_themes() -> Array[PuzzleTheme]:
	var ent: PuzzleTheme = Pandora.get_entity(PuzzleThemeIDs.DEBUG)
	if ent == null:
		Log.warn("no DEBUG theme entity found. Is Pandora data loaded?")
		return []
	var ths: Array = Pandora.get_all_entities(Pandora.get_category(ent._category_id))\
		.map(func(e: PandoraEntity) -> PuzzleTheme: return e.instantiate())
	var th: Array[PuzzleTheme] = []
	th.assign(ths)
	return th

## helpers #######################################################

func find_world(world: PuzzleWorld) -> Variant:
	for w: PuzzleWorld in worlds:
		# assumes world instances and entities are 1:1, which seems fine
		if w.get_entity_id() == world.get_entity_id():
			return w
	return

func find_theme(theme: PuzzleTheme) -> Variant:
	for th: PuzzleTheme in themes:
		# assumes world instances and entities are 1:1, which seems fine
		if th.get_entity_id() == theme.get_entity_id():
			return th
	return

## stats ###########################################################

func attach_gameplay_data() -> void:
	for world: PuzzleWorld in worlds:
		world.attach_gameplay_data()
