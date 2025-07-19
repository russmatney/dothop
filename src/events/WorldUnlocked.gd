@tool
extends Event
class_name WorldUnlocked

func get_world() -> PuzzleWorld:
	return Pandora.get_entity(get_string("world_id")) as PuzzleWorld

func get_world_id() -> String:
	return get_string("world_id")

func data() -> Dictionary:
	var d: Dictionary = super.data()
	d.merge({world=get_world(),})
	return d

static func new_event(world: PuzzleWorld) -> WorldUnlocked:
	var event: WorldUnlocked = Pandora.get_entity(EventIds.WORLDUNLOCKEDEVENT).instantiate()
	event.set_string("world_id", world.get_entity_id())
	event.set_event_data({
		world=world,
		display_name="%s unlocked" % world.get_display_name(),
		})
	return event

static func is_matching_event(event: Event, world: PuzzleWorld) -> bool:
	if not event is WorldUnlocked:
		return false
	return (event as WorldUnlocked).get_world_id() == world.get_entity_id()
