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
	assert_that(len(unlocked)).is_greater(1)

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

	# only one unlocked theme
	var unlocked = themes.filter(func(ent): return ent.is_unlocked())
	# TODO theme unlocking!
	assert_that(len(unlocked)).is_equal(len(theme_ents))

#########################################################################
## completing and unlocking puzzle sets

func test_unlocking_puzzle_set():
	Store.reset_game_data()

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

	# in-place entity updates
	assert_that(next.is_unlocked()).is_true()

	# re-pulled entity updates as well
	var _next = Store.get_puzzle_sets().filter(func(e): return e.get_entity_id() == next_id)[0]
	assert_that(_next.is_unlocked()).is_true()

	# do it again, unlocking the 'next-next' puzzle
	Store.complete_puzzle_set(next)
	var third = Store.get_puzzle_sets().filter(func(e):
		return e.get_entity_id() == next.get_next_puzzle_set().get_entity_id())[0]
	assert_that(third.is_unlocked()).is_true()
