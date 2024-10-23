extends GdUnitTestSuite

# probably want to update SaveGame to point to some test save file

#########################################################################
## initial data

func test_initial_store_puzzle_data():
	Store.reset_game_data()

	var p_ent = Pandora.get_entity(PuzzleSetIDs.THEMDOTS)
	var puzzle_ents = Pandora.get_all_entities(Pandora.get_category(p_ent._category_id))
	assert_that(len(puzzle_ents)).is_greater(2)

	var sets = Store.get_puzzle_sets()

	# test that we get as many sets as entities
	assert_that(len(sets)).is_equal(len(puzzle_ents))

	# at least one unlocked puzzle set
	var unlocked = sets.filter(func(ent): return ent.is_unlocked())
	assert_that(len(unlocked)).is_greater(0)

	# all but one set point to a next_puzzle_set
	var have_next = sets.filter(func(ent): return ent.get_next_puzzle_set())
	assert_that(len(have_next)).is_equal(len(sets) - 1)

func test_initial_store_theme_data():
	Store.reset_game_data()

	var t_ent = Pandora.get_entity(PuzzleThemeIDs.DEBUG)
	var theme_ents = Pandora.get_all_entities(Pandora.get_category(t_ent._category_id))
	assert_that(len(theme_ents)).is_greater(2)

	var themes = Store.get_themes()

	# test that we get as many themes as entities
	assert_that(len(themes)).is_equal(len(theme_ents))

	# at least one theme unlocked
	var unlocked = themes.filter(func(ent): return ent.is_unlocked())
	assert_that(len(unlocked)).is_greater(0)

#########################################################################
## completing and unlocking puzzle sets

func test_completing_puzzle_set():
	Store.reset_game_data()
	assert_that(len(Store.events)).is_equal(0)

	# get an unlocked puzzle and it's 'next' puzzle
	var sets = Store.get_puzzle_sets()
	var first = sets.filter(func(e): return not e.is_completed())[0]
	Store.complete_puzzle_set(first)

	assert_that(first.is_completed()).is_true()

	assert_that(len(Store.events)).is_equal(1)
	var ev = Store.events[0]
	assert_that(ev.get_puzzle_set().get_entity_id()).is_equal(first.get_entity_id())


func test_unlocking_puzzle_set():
	Store.reset_game_data()
	assert_that(len(Store.events)).is_equal(0)

	# get an locked puzzle and it's 'next' puzzle
	var sets = Store.get_puzzle_sets()
	var first = sets.filter(func(e): return not e.is_unlocked())[0]
	var first_id = first.get_entity_id()

	# ensure it's not unlocked already!
	assert_that(first.is_unlocked()).is_false()

	# unlock it
	Store.unlock_puzzle_set(first)

	# should have one event created
	assert_that(len(Store.events)).is_equal(1)
	var ev = Store.events[0]
	assert_that(ev.get_puzzle_set().get_entity_id()).is_equal(first_id)

	# in-place entity updates
	assert_that(first.is_unlocked()).is_true()

	# re-pulled entity updates as well
	var _first = Store.find_puzzle_set(first)
	assert_that(_first.is_unlocked()).is_true()

	# reloaded data shows the same
	Store.load_game()
	_first = Store.find_puzzle_set(first)
	assert_that(_first.is_unlocked()).is_true()


#########################################################################
## completing puzzles

func test_completing_a_puzzle(indexes, test_parameters=[[[0]], [[0, 1]], [[0, 1, 2]]]):
	Store.reset_game_data()
	assert_that(len(Store.events)).is_equal(0)

	var sets = Store.get_puzzle_sets()
	var puz_set = sets.filter(func(e): return not e.is_completed())[0]

	var idx = indexes[-1]

	for i in indexes:
		Store.complete_puzzle_index(puz_set, i)

	# get an unlocked puzzle
	assert_that(puz_set.get_max_completed_puzzle_index()).is_equal(idx)

	assert_that(len(Store.events)).is_equal(idx + 1)
	var ev = Store.events[idx]
	assert_that(ev.get_puzzle_set().get_entity_id()).is_equal(puz_set.get_entity_id())
	assert_that(ev.get_puzzle_index()).is_equal(idx)

	assert_that(puz_set.can_play_puzzle(idx)).is_true()
	assert_that(puz_set.can_play_puzzle(idx + 1)).is_true()
	assert_that(puz_set.can_play_puzzle(idx + 2)).is_true()
	assert_that(puz_set.can_play_puzzle(idx + 3)).is_true()
	assert_that(puz_set.can_play_puzzle(idx + 4)).is_false()

#########################################################################
## skipping puzzles

func test_skipping_a_puzzle():
	Store.reset_game_data()
	assert_that(len(Store.events)).is_equal(0)

	var puz_set = Store.get_puzzle_sets().filter(func(e): return not e.is_completed())[0]

	Store.complete_puzzle_index(puz_set, 0)
	Store.complete_puzzle_index(puz_set, 1)
	Store.skip_puzzle(puz_set, 2)
	Store.complete_puzzle_index(puz_set, 3)

	assert_that(len(Store.events)).is_equal(4)

	assert_that(puz_set.completed_puzzle_count()).is_equal(3)
	assert_that(puz_set.skipped_puzzle_count()).is_equal(1)

	var puz_defs = puz_set.get_puzzles()
	assert_that(puz_defs[0].is_completed).is_true()
	assert_that(puz_defs[1].is_completed).is_true()
	assert_that(puz_defs[1].is_skipped).is_false()
	assert_that(puz_defs[2].is_completed).is_false()
	assert_that(puz_defs[2].is_skipped).is_true()
	assert_that(puz_defs[3].is_completed).is_true()

	# repeat after reloading
	Store.load_game()
	assert_that(puz_set.completed_puzzle_count()).is_equal(3)
	assert_that(puz_set.skipped_puzzle_count()).is_equal(1)

	puz_defs = puz_set.get_puzzles()
	assert_that(puz_defs[0].is_completed).is_true()
	assert_that(puz_defs[1].is_completed).is_true()
	assert_that(puz_defs[1].is_skipped).is_false()
	assert_that(puz_defs[2].is_completed).is_false()
	assert_that(puz_defs[2].is_skipped).is_true()
	assert_that(puz_defs[3].is_completed).is_true()

	# now complete the puzzle
	Store.complete_puzzle_index(puz_set, 2)

	# refetching from the store to get the updated data
	puz_set = Store.get_puzzle_sets().filter(func(e): return not e.is_completed())[0]
	puz_defs = puz_set.get_puzzles()

	assert_that(puz_defs[0].is_completed).is_true()
	assert_that(puz_defs[1].is_completed).is_true()
	assert_that(puz_defs[1].is_skipped).is_false()
	assert_that(puz_defs[2].is_completed).is_true()
	assert_that(puz_defs[2].is_skipped).is_false()
	assert_that(puz_defs[3].is_completed).is_true()

	Store.load_game()

	assert_that(puz_defs[0].is_completed).is_true()
	assert_that(puz_defs[1].is_completed).is_true()
	assert_that(puz_defs[1].is_skipped).is_false()
	assert_that(puz_defs[2].is_completed).is_true()
	assert_that(puz_defs[2].is_skipped).is_false()
	assert_that(puz_defs[3].is_completed).is_true()

#########################################################################
## dupe events

func test_complete_puzzle_idx_dupe_events_increment_count():
	Store.reset_game_data()
	assert_that(len(Store.events)).is_equal(0)

	var sets = Store.get_puzzle_sets()
	var puz_set = sets.filter(func(e): return not e.is_completed())[0]

	Store.complete_puzzle_index(puz_set, 0)
	Store.complete_puzzle_index(puz_set, 0)

	assert_that(len(Store.events)).is_equal(1)
	var ev = Store.events[0]
	assert_that(ev.get_puzzle_set().get_entity_id()).is_equal(puz_set.get_entity_id())
	assert_that(ev.get_puzzle_index()).is_equal(0)
	assert_that(ev.get_count()).is_equal(2)

	assert_that(len(Store.events)).is_equal(1)

	Store.complete_puzzle_index(puz_set, 0)
	assert_that(ev.get_count()).is_equal(3)

func test_puzzle_set_complete_and_unlock_dupe_events_increment_count():
	Store.reset_game_data()
	assert_that(len(Store.events)).is_equal(0)

	var sets = Store.get_puzzle_sets()
	var puz_set = sets.filter(func(e): return not e.is_completed())[0]

	Store.complete_puzzle_set(puz_set)
	Store.complete_puzzle_set(puz_set)
	Store.complete_puzzle_set(puz_set)
	Store.unlock_next_puzzle_set(puz_set)
	Store.unlock_next_puzzle_set(puz_set)

	assert_that(len(Store.events)).is_equal(2)
	var ev = Store.events[0]
	assert_that(ev.get_puzzle_set().get_entity_id()).is_equal(puz_set.get_entity_id())
	assert_that(ev.get_count()).is_equal(3)

	ev = Store.events[1]
	assert_that(ev.get_puzzle_set().get_entity_id()).is_equal(puz_set.get_next_puzzle_set().get_entity_id())
	assert_that(ev.get_count()).is_equal(2)
