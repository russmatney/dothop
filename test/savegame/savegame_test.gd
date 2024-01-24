extends GdUnitTestSuite

func test_basic_round_trip():
	var data = {
		my_special="value",
		roundtrips=["flaw", "less", 3.0, "ly",
			{even="WITH", nested={data=true}}],
		# vectors don't roundtrip :/
		# vector=Vector3(2.0, 3.4, 1.0),
		# vec2=[Vector2(0.4, 21.0), Vector2(0.6, 0.7)],
		something=null,
		}

	SaveGame.save_game(get_tree(), data)

	var loaded = SaveGame.load_game(get_tree())

	assert_dict(loaded).is_equal(data)

# TODO how to support migrating savegames across code changes/versions
# maybe we need to version the save games and keep the old code around?
# or keep all possible versions of savegames to be sure they're all parsable?
