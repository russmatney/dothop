@tool
extends Event
class_name PuzzleSetCompleted

func get_puzzle_set() -> PuzzleSet:
	return Pandora.get_entity(get_string("puzzle_set_id")) as PuzzleSet

func get_puzzle_set_id() -> String:
	return get_string("puzzle_set_id")

func data() -> Variant:
	var d: Dictionary = super.data()
	d.merge({puzzle_set=get_puzzle_set(),})
	return d

static func new_event(puzzle_set: PuzzleSet) -> PuzzleSetCompleted:
	var event: PuzzleSetCompleted = Pandora.get_entity(EventIds.PUZZLESETCOMPLETEDEVENT).instantiate()
	event.set_string("puzzle_set_id", puzzle_set.get_entity_id())
	event.set_event_data({
		puzzle_set=puzzle_set,
		display_name="%s completed" % puzzle_set.get_display_name(),
		})
	return event

static func is_matching_event(event: Event, puzzle_set: PuzzleSet) -> bool:
	if not event is PuzzleSetCompleted:
		return false
	return (event as PuzzleSetCompleted).get_puzzle_set_id() == puzzle_set.get_entity_id()
