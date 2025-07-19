@tool
extends Event
class_name PuzzleCompleted

func get_world() -> PuzzleWorld:
	return Pandora.get_entity(get_string("world_id")) as PuzzleWorld

func get_world_id() -> String:
	return get_string("world_id")

func get_puzzle_index() -> int:
	return get_integer("puzzle_idx")

func data() -> Variant:
	var d: Dictionary = super.data()
	d.merge({
		world=get_world().get_display_name(),
		puzzle_index=get_puzzle_index(),
		})
	return d

static func new_event(world: PuzzleWorld, puzzle_idx: int) -> PuzzleCompleted:
	var event: PuzzleCompleted = Pandora.get_entity(EventIds.PUZZLECOMPLETEDEVENT).instantiate()
	event.set_string("world_id", world.get_entity_id())
	event.set_integer("puzzle_idx", puzzle_idx)
	event.set_event_data({
		world=world,
		display_name="Puzzle %s completed in set '%s'" % [puzzle_idx, world.get_display_name()],
		})
	return event

static func is_matching_event(event: Event, world: PuzzleWorld, idx: int) -> bool:
	if not event is PuzzleCompleted:
		return false
	return (event as PuzzleCompleted).get_world_id() == world.get_entity_id() and \
		(event as PuzzleCompleted).get_puzzle_index() == idx
