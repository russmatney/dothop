@tool
extends Event
class_name PuzzleSetUnlocked

func get_puzzle_set() -> PuzzleSet:
	return Pandora.get_entity(get_string("puzzle_set_id")) as PuzzleSet

func get_puzzle_set_id() -> String:
	return get_string("puzzle_set_id")

func data():
	var d = super.data()
	d.merge({puzzle_set=get_puzzle_set(),})
	return d

static func new_event(puzzle_set: PuzzleSet):
	var event = Pandora.get_entity(EventIds.PUZZLESETUNLOCKEDEVENT).instantiate()
	event.set_string("puzzle_set_id", puzzle_set.get_entity_id())
	event.set_event_data({
		puzzle_set=puzzle_set,
		display_name="%s unlocked" % puzzle_set.get_display_name(),
		})
	return event

static func is_matching_event(event, puzzle_set: PuzzleSet):
	if not event is PuzzleSetUnlocked:
		return false
	return event.get_puzzle_set_id() == puzzle_set.get_entity_id()
