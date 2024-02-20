extends GdUnitTestSuite

# probably want to update SaveGame to point to some test save file

#########################################################################
## initial data

func test_initial_store_puzzle_data():
	Store.reset_game_data()

	var p_ent = Pandora.get_entity(PuzzleSetIDs.ONE)
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

	# all themes unlocked (for now)
	var unlocked = themes.filter(func(ent): return ent.is_unlocked())
	assert_that(len(unlocked)).is_equal(len(theme_ents))

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

	assert_that(len(Store.events)).is_equal(2) # includes 'unlocking' event
	var ev = Store.events[0]
	assert_that(ev.get_puzzle_set().get_entity_id()).is_equal(first.get_entity_id())


func test_unlocking_puzzle_set():
	Store.reset_game_data()
	assert_that(len(Store.events)).is_equal(0)

	# get an unlocked puzzle and it's 'next' puzzle
	var sets = Store.get_puzzle_sets()
	var first = sets.filter(func(e): return e.is_unlocked())[0]
	var next_id = first.get_next_puzzle_set().get_entity_id()
	var next = sets.filter(func(e): return e.get_entity_id() == next_id)[0]

	# ensure it's not unlocked already!
	assert_that(next.is_unlocked()).is_false()

	# complete the current (which for now also unlocks the 'next' puzzle)
	Store.complete_puzzle_set(first)

	# should have two events created
	assert_that(len(Store.events)).is_equal(2)
	var ev = Store.events[1]
	assert_that(ev.get_puzzle_set().get_entity_id()).is_equal(next.get_entity_id())

	# in-place entity updates
	assert_that(next.is_unlocked()).is_true()

	# re-pulled entity updates as well
	var _next = Store.get_puzzle_sets().filter(func(e): return e.get_entity_id() == next_id)[0]
	assert_that(_next.is_unlocked()).is_true()

	# reloaded data shows the same
	Store.load_game()
	_next = Store.get_puzzle_sets().filter(func(e): return e.get_entity_id() == next_id)[0]
	assert_that(_next.is_unlocked()).is_true()

	####################

	# do it again, unlocking the 'next-next' puzzle
	Store.complete_puzzle_set(next)
	var third = Store.get_puzzle_sets().filter(func(e):
		return e.get_entity_id() == next.get_next_puzzle_set().get_entity_id())[0]
	assert_that(third.is_unlocked()).is_true()

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
	assert_that(puz_set.can_play_puzzle(idx + 2)).is_false()

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
	assert_that(ev.get_count()).is_equal(5) # b/c the 'completed' event also unlocks these
