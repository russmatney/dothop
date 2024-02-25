@tool
extends Event
class_name PuzzleSkipped

func get_puzzle_set() -> PuzzleSet:
	return Pandora.get_entity(get_string("puzzle_set_id")) as PuzzleSet

func get_puzzle_set_id() -> String:
	return get_string("puzzle_set_id")

func get_puzzle_index() -> int:
	return get_integer("puzzle_idx")

func data():
	var d = super.data()
	d.merge({
		puzzle_set=get_puzzle_set(),
		puzzle_index=get_puzzle_index(),
		})
	return d

static func new_event(puzzle_set: PuzzleSet, puzzle_idx: int):
	var event = Pandora.get_entity(EventIds.PUZZLESKIPPEDEVENT).instantiate()
	event.set_string("puzzle_set_id", puzzle_set.get_entity_id())
	event.set_integer("puzzle_idx", puzzle_idx)
	event.set_event_data({
		puzzle_set=puzzle_set,
		display_name="Puzzle %s skipped in set '%s'" % [puzzle_idx, puzzle_set.get_display_name()],
		})
	return event

static func is_matching_event(event, puzzle_set: PuzzleSet, idx: int):
	if not event is PuzzleSkipped:
		return false
	return event.get_puzzle_set_id() == puzzle_set.get_entity_id() and \
		event.get_puzzle_index() == idx
