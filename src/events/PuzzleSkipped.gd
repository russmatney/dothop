@tool
extends Event
class_name PuzzleSkipped

func get_world() -> PuzzleWorld:
	return Pandora.get_entity(get_string("world_id")) as PuzzleWorld

func get_world_id() -> String:
	return get_string("world_id")

func get_puzzle_index() -> int:
	return get_integer("puzzle_idx")

func is_active() -> bool:
	return get_bool("is_active")

func data() -> Variant:
	var d: Dictionary = super.data()
	d.merge({
		is_active=is_active(),
		world=get_world().get_display_name(),
		puzzle_index=get_puzzle_index(),
		})
	return d

static func new_event(world: PuzzleWorld, puzzle_idx: int) -> Event:
	var event: PuzzleSkipped = Pandora.get_entity(EventIds.PUZZLESKIPPEDEVENT).instantiate()
	event.set_string("world_id", world.get_entity_id())
	event.set_integer("puzzle_idx", puzzle_idx)
	event.set_event_data({
		world=world,
		display_name="Puzzle %s skipped in set '%s'" % [puzzle_idx, world.get_display_name()],
		})
	return event

static func is_matching_event(event: Event, world: PuzzleWorld, idx: int) -> bool:
	if not event is PuzzleSkipped:
		return false
	return (event as PuzzleSkipped).get_world_id() == world.get_entity_id() and \
		(event as PuzzleSkipped).get_puzzle_index() == idx

func mark_inactive() -> void:
	set_bool("is_active", false)
