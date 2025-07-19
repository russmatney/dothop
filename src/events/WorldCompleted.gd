@tool
extends Event
class_name WorldCompleted

func get_world() -> PuzzleWorld:
	return Pandora.get_entity(get_string("world_id")) as PuzzleWorld

func get_world_id() -> String:
	return get_string("world_id")

func data() -> Variant:
	var d: Dictionary = super.data()
	d.merge({world=get_world(),})
	return d

static func new_event(world: PuzzleWorld) -> WorldCompleted:
	var event: WorldCompleted = Pandora.get_entity(EventIds.WORLDCOMPLETEDEVENT).instantiate()
	event.set_string("world_id", world.get_entity_id())
	event.set_event_data({
		world=world,
		display_name="%s completed" % world.get_display_name(),
		})
	return event

static func is_matching_event(event: Event, world: PuzzleWorld) -> bool:
	if not event is WorldCompleted:
		return false
	return (event as WorldCompleted).get_world_id() == world.get_entity_id()
