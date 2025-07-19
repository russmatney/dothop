@tool
extends Event
class_name PuzzleCompleted

func get_puzzle_set() -> PuzzleWorld:
	return Pandora.get_entity(get_string("puzzle_set_id")) as PuzzleWorld

func get_puzzle_set_id() -> String:
	return get_string("puzzle_set_id")

func get_puzzle_index() -> int:
	return get_integer("puzzle_idx")

func data() -> Variant:
	var d: Dictionary = super.data()
	d.merge({
		puzzle_set=get_puzzle_set().get_display_name(),
		puzzle_index=get_puzzle_index(),
		})
	return d

static func new_event(puzzle_set: PuzzleWorld, puzzle_idx: int) -> PuzzleCompleted:
	var event: PuzzleCompleted = Pandora.get_entity(EventIds.PUZZLECOMPLETEDEVENT).instantiate()
	event.set_string("puzzle_set_id", puzzle_set.get_entity_id())
	event.set_integer("puzzle_idx", puzzle_idx)
	event.set_event_data({
		puzzle_set=puzzle_set,
		display_name="Puzzle %s completed in set '%s'" % [puzzle_idx, puzzle_set.get_display_name()],
		})
	return event

static func is_matching_event(event: Event, puzzle_set: PuzzleWorld, idx: int) -> bool:
	if not event is PuzzleCompleted:
		return false
	return (event as PuzzleCompleted).get_puzzle_set_id() == puzzle_set.get_entity_id() and \
		(event as PuzzleCompleted).get_puzzle_index() == idx
