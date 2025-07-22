extends GdUnitTestSuite

# probably want to update SaveGame to point to some test save file

#########################################################################
## initial data

func test_initial_store_puzzle_data() -> void:
	Store.reset_game_data()

	var p_ent := Pandora.get_entity(PuzzleWorldIDs.THEMDOTS)
	var puzzle_ents := Pandora.get_all_entities(Pandora.get_category(p_ent._category_id))
	assert_int(len(puzzle_ents)).is_greater(2)

	var sets := Store.get_worlds()

	# test that we get as many sets as entities
	assert_that(len(sets)).is_equal(len(puzzle_ents))

	# at least one unlocked puzzle set
	var unlocked := sets.filter(func(ent: PuzzleWorld) -> bool: return ent.is_unlocked())
	assert_int(len(unlocked)).is_greater(0)

func test_initial_store_theme_data() -> void:
	Store.reset_game_data()

	var t_ent := Pandora.get_entity(PuzzleThemeIDs.DEBUG)
	var theme_ents := Pandora.get_all_entities(Pandora.get_category(t_ent._category_id))
	assert_int(len(theme_ents)).is_greater(2)

	var themes := Store.get_themes()

	# test that we get as many themes as entities
	assert_that(len(themes)).is_equal(len(theme_ents))

	# at least one theme unlocked
	var unlocked := themes.filter(func(ent: PuzzleTheme) -> bool: return ent.is_unlocked())
	assert_int(len(unlocked)).is_greater(0)

#########################################################################
## completing and unlocking puzzle sets

func test_completing_world() -> void:
	Store.reset_game_data()
	assert_that(len(Store.events)).is_equal(0)

	# get an unlocked puzzle and it's 'next' puzzle
	var sets := Store.get_worlds()
	var first: PuzzleWorld = sets.filter(func(e: PuzzleWorld) -> bool: return not e.is_completed())[0]
	Store.complete_world(first)

	assert_bool(first.is_completed()).is_true()

	assert_that(len(Store.events)).is_equal(1)
	var ev := Store.events[0]
	@warning_ignore("unsafe_method_access")
	assert_that(ev.get_world().get_entity_id()).is_equal(first.get_entity_id())


func test_unlocking_world() -> void:
	Store.reset_game_data()
	assert_that(len(Store.events)).is_equal(0)

	# get an locked puzzle and it's 'next' puzzle
	var sets := Store.get_worlds()
	var first: PuzzleWorld = sets.filter(func(e: PuzzleWorld) -> bool: return not e.is_unlocked())[0]
	var first_id := first.get_entity_id()

	# ensure it's not unlocked already!
	assert_bool(first.is_unlocked()).is_false()

	# unlock it
	Store.unlock_world(first)

	# should have one event created
	assert_that(len(Store.events)).is_equal(1)
	var ev := Store.events[0]
	@warning_ignore("unsafe_method_access")
	assert_that(ev.get_world().get_entity_id()).is_equal(first_id)

	# in-place entity updates
	assert_bool(first.is_unlocked()).is_true()

	# re-pulled entity updates as well
	var _first := Store.find_world(first)
	assert_bool(_first.is_unlocked()).is_true()

	# reloaded data shows the same
	Store.load_game()
	_first = Store.find_world(first)
	assert_bool(_first.is_unlocked()).is_true()


#########################################################################
## completing puzzles

@warning_ignore("unused_parameter")
func test_completing_a_puzzle(indexes: Array, test_parameters: Variant = [[[0]], [[0, 1]], [[0, 1, 2]]]) -> void:
	Store.reset_game_data()
	assert_that(len(Store.events)).is_equal(0)

	var sets := Store.get_worlds()
	var puz_set: PuzzleWorld = sets.filter(func(e: PuzzleWorld) -> bool: return not e.is_completed())[0]

	var idx: int = indexes[-1]

	for i: int in indexes:
		Store.complete_puzzle_index(puz_set, i)

	# get an unlocked puzzle
	assert_that(puz_set.get_max_completed_puzzle_index()).is_equal(idx)

	assert_that(len(Store.events)).is_equal(idx + 1)
	var ev := Store.events[idx]
	@warning_ignore("unsafe_method_access")
	assert_that(ev.get_world().get_entity_id()).is_equal(puz_set.get_entity_id())
	@warning_ignore("unsafe_method_access")
	assert_that(ev.get_puzzle_index()).is_equal(idx)

	assert_bool(puz_set.can_play_puzzle(idx)).is_true()
	assert_bool(puz_set.can_play_puzzle(idx + 1)).is_true()
	assert_bool(puz_set.can_play_puzzle(idx + 2)).is_true()
	assert_bool(puz_set.can_play_puzzle(idx + 3)).is_true()
	assert_bool(puz_set.can_play_puzzle(idx + 4)).is_false()

#########################################################################
## skipping puzzles

func test_skipping_a_puzzle() -> void:
	Store.reset_game_data()
	assert_that(len(Store.events)).is_equal(0)

	var puz_set: PuzzleWorld = Store.get_worlds()\
		.filter(func(e: PuzzleWorld) -> bool: return not e.is_completed())[0]

	Store.complete_puzzle_index(puz_set, 0)
	Store.complete_puzzle_index(puz_set, 1)
	Store.skip_puzzle(puz_set, 2)
	Store.complete_puzzle_index(puz_set, 3)

	assert_that(len(Store.events)).is_equal(4)

	assert_that(puz_set.completed_puzzle_count()).is_equal(3)
	assert_that(puz_set.skipped_puzzle_count()).is_equal(1)

	var puz_defs := puz_set.get_puzzles()
	assert_bool(puz_defs[0].is_completed).is_true()
	assert_bool(puz_defs[1].is_completed).is_true()
	assert_bool(puz_defs[1].is_skipped).is_false()
	assert_bool(puz_defs[2].is_completed).is_false()
	assert_bool(puz_defs[2].is_skipped).is_true()
	assert_bool(puz_defs[3].is_completed).is_true()

	# repeat after reloading
	Store.load_game()
	assert_that(puz_set.completed_puzzle_count()).is_equal(3)
	assert_that(puz_set.skipped_puzzle_count()).is_equal(1)

	puz_defs = puz_set.get_puzzles()
	assert_bool(puz_defs[0].is_completed).is_true()
	assert_bool(puz_defs[1].is_completed).is_true()
	assert_bool(puz_defs[1].is_skipped).is_false()
	assert_bool(puz_defs[2].is_completed).is_false()
	assert_bool(puz_defs[2].is_skipped).is_true()
	assert_bool(puz_defs[3].is_completed).is_true()

	# now complete the puzzle
	Store.complete_puzzle_index(puz_set, 2)

	# refetching from the store to get the updated data
	puz_set = Store.get_worlds().filter(func(e: PuzzleWorld) -> bool: return not e.is_completed())[0]
	puz_defs = puz_set.get_puzzles()

	assert_bool(puz_defs[0].is_completed).is_true()
	assert_bool(puz_defs[1].is_completed).is_true()
	assert_bool(puz_defs[1].is_skipped).is_false()
	assert_bool(puz_defs[2].is_completed).is_true()
	assert_bool(puz_defs[2].is_skipped).is_false()
	assert_bool(puz_defs[3].is_completed).is_true()

	Store.load_game()

	assert_bool(puz_defs[0].is_completed).is_true()
	assert_bool(puz_defs[1].is_completed).is_true()
	assert_bool(puz_defs[1].is_skipped).is_false()
	assert_bool(puz_defs[2].is_completed).is_true()
	assert_bool(puz_defs[2].is_skipped).is_false()
	assert_bool(puz_defs[3].is_completed).is_true()

#########################################################################
## dupe events

func test_complete_puzzle_idx_dupe_events_increment_count() -> void:
	Store.reset_game_data()
	assert_that(len(Store.events)).is_equal(0)

	var sets := Store.get_worlds()
	var puz_set: PuzzleWorld = sets.filter(func(e: PuzzleWorld) -> bool: return not e.is_completed())[0]

	Store.complete_puzzle_index(puz_set, 0)
	Store.complete_puzzle_index(puz_set, 0)

	assert_that(len(Store.events)).is_equal(1)
	var ev := Store.events[0]
	@warning_ignore("unsafe_method_access")
	assert_that(ev.get_world().get_entity_id()).is_equal(puz_set.get_entity_id())
	@warning_ignore("unsafe_method_access")
	assert_that(ev.get_puzzle_index()).is_equal(0)
	assert_that(ev.get_count()).is_equal(2)

	assert_that(len(Store.events)).is_equal(1)

	Store.complete_puzzle_index(puz_set, 0)
	assert_that(ev.get_count()).is_equal(3)

func test_world_complete_and_unlock_dupe_events_increment_count() -> void:
	Store.reset_game_data()
	assert_that(len(Store.events)).is_equal(0)

	var sets := Store.get_worlds()
	var world: PuzzleWorld = sets.filter(func(e: PuzzleWorld) -> bool: return not e.is_completed())[0]

	Store.complete_world(world)
	Store.complete_world(world)
	Store.complete_world(world)

	assert_that(len(Store.events)).is_equal(1)
	var ev := Store.events[0]
	@warning_ignore("unsafe_method_access")
	assert_that(ev.get_world().get_entity_id()).is_equal(world.get_entity_id())
	assert_that(ev.get_count()).is_equal(3)

	var unlocked_wrd: PuzzleWorld = sets.filter(func(e: PuzzleWorld) -> bool: return not e.is_unlocked())[0]
	Store.unlock_world(unlocked_wrd)
	Store.unlock_world(unlocked_wrd)

	assert_that(len(Store.events)).is_equal(2)
	ev = Store.events[1]
	@warning_ignore("unsafe_method_access")
	assert_that(ev.get_world().get_entity_id()).is_equal(unlocked_wrd.get_entity_id())
	assert_that(ev.get_count()).is_equal(2)
