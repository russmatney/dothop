@tool
extends Node

## _ready ###########################################

func _ready():
	load_game()

## data store ###########################################

var state: GameState

# var events: Array[Events] = []
var events: Array = []

# event types

# puzzle_set_completed
#  - puzzle_set entity_id
#  - completed_at timestamp
#  - display_name

# puzzle_set_unlocked
#  - puzzle_set entity_id
#  - unlocked_at timestamp
#  - display_name

func save_game():
	SaveGame.save_game(get_tree(), {
		events=events.map(Pandora.serialize),
		})

func load_game():
	var data = SaveGame.load_game(get_tree())

	if not "events" in data or len(data.events) == 0:
		events = initial_events()
	else:
		Log.pr("Loading saved events")
		events.assign(data.events.map(Pandora.deserialize))

	state = GameState.new(events)

	Log.pr("Loaded data", {
		events=len(events), puzzle_sets=len(state.puzzle_sets), themes=len(state.themes)
		})

	# TODO validation and basic recovery from crashes on loaded data?
	# i.e. missing puzzle_sets, at least set the initial ones and get to playable state

func reset_game_data():
	SaveGame.delete_save()
	load_game()

## initial data ###########################################

func initial_events() -> Array:
	return []

## repository ###########################################

func get_puzzle_sets() -> Array[PuzzleSet]:
	return state.puzzle_sets

func get_themes() -> Array[DotHopTheme]:
	return state.themes

func get_events() -> Array:
	return events

## events ###########################################

func complete_puzzle_set(puz: PuzzleSet):
	# TODO create, apply, and save puzzle_set_unlocked event
	var event_cat = Pandora.get_category("PuzzleSetCompleted")
	var event_ent = Pandora.create_entity("%s complete!" % puz.get_display_name(), event_cat)
	var event = event_ent.instantiate()
	# TODO event.set_* puzzle, timestamps, display_name, etc
	events.append(event)
	save_game()

	if puz.get_next_puzzle_set():
		unlock_next_puzzle_set(puz)

func unlock_next_puzzle_set(puz: PuzzleSet):
	# TODO create, apply, and save puzzle_set_unlocked event
	# move this logic to GameState and make it a result of applying the event
	if puz.get_next_puzzle_set():
		var to_unlock = state.puzzle_sets.filter(func(ps):
			return ps.get_entity_id() == puz.get_next_puzzle_set().get_entity_id())
		if len(to_unlock) > 0:
			var next = to_unlock[0]

			var event_cat = Pandora.get_category("PuzzleSetUnlocked")
			var event_ent = Pandora.create_entity("%s unlocked!" % next.get_display_name(), event_cat)
			var event = event_ent.instantiate()
			events.append(event)
			# TODO event.set_* puzzle, timestamps, display_name, etc

			# TODO unlock for immediate use
			next.unlock()
			# save update events for later reloading
			save_game()
	else:
		Log.warn("No next puzzle to unlock!", puz)
