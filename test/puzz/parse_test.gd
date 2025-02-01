extends GdUnitTestSuite

func parse() -> Dictionary:
	var path := "res://test/puzz/simple_block_pushing_game.ps"
	return Puzz.parse_game_def(path).raw

var parsed: Dictionary

func before() -> void:
	parsed = parse()

func test_prelude() -> void:
	assert_dict(parsed).contains_keys(["prelude"])
	assert_that(parsed.prelude.title).is_equal("Simple Block Pushing Game")
	assert_that(parsed.prelude.author).is_equal("David Skinner")
	assert_that(parsed.prelude.homepage).is_equal("www.puzzlescript.net")
	assert_that(parsed.prelude.debug).is_equal(true)


func test_objects() -> void:
	assert_dict(parsed).contains_keys(["objects"])

func test_objects_background() -> void:
	assert_dict(parsed.objects).contains_keys(["Background"])
	assert_that(parsed.objects.Background.name).is_equal("Background")
	assert_that(parsed.objects.Background.colors).is_equal(["lightgreen", "green"])
	assert_that(parsed.objects.Background.shape).is_equal([
		[1, 1, 1, 1, 1],
		[0, 1, 1, 1, 1],
		[1, 1, 1, 0, 1],
		[1, 1, 1, 1, 1],
		[1, 0, 1, 1, 1],
		])

func test_objects_target() -> void:
	assert_dict(parsed.objects).contains_keys(["Target"])
	assert_that(parsed.objects.Target.name).is_equal("Target")
	assert_that(parsed.objects.Target.colors).is_equal(["darkblue"])
	assert_that(parsed.objects.Target.shape).is_equal([
		[null, null, null, null, null],
		[null, 0, 0, 0, null],
		[null, 0, null, 0, null],
		[null, 0, 0, 0, null],
		[null, null, null, null, null],
		])

func test_objects_wall() -> void:
	assert_dict(parsed.objects).contains_keys(["Wall"])
	assert_that(parsed.objects.Wall.name).is_equal("Wall")
	assert_that(parsed.objects.Wall.colors).is_equal(["brown", "darkbrown"])
	assert_that(parsed.objects.Wall.shape).is_equal([
		[0, 0, 0, 1, 0],
		[1, 1, 1, 1, 1],
		[0, 1, 0, 0, 0],
		[1, 1, 1, 1, 1],
		[0, 0, 0, 1, 0],
		])

func test_objects_player() -> void:
	assert_dict(parsed.objects).contains_keys(["Player"])
	assert_that(parsed.objects.Player.name).is_equal("Player")
	assert_that(parsed.objects.Player.symbol).is_equal("P")
	assert_that(parsed.objects.Player.colors).is_equal(["black", "orange", "white", "blue"])
	assert_that(parsed.objects.Player.shape).is_equal([
		[null, 0, 0, 0, null],
		[null, 1, 1, 1, null],
		[2, 2, 2, 2, 2],
		[null, 3, 3, 3, null],
		[null, 3, null, 3, null],
		])

func test_objects_crate() -> void:
	assert_dict(parsed.objects).contains_keys(["Crate"])
	assert_that(parsed.objects.Crate.name).is_equal("Crate")
	assert_that(parsed.objects.Crate.colors).is_equal(["orange"])
	assert_that(parsed.objects.Crate.shape).is_equal([
		[0, 0, 0, 0, 0],
		[0, null, null, null, 0],
		[0, null, null, null, 0],
		[0, null, null, null, 0],
		[0, 0, 0, 0, 0],
		])

func test_legend() -> void:
	assert_dict(parsed).contains_keys(["legend"])

	# add coverage for 'and' vs 'or'
	assert_that(parsed.legend["."]).is_equal(["Background"])
	assert_that(parsed.legend["#"]).is_equal(["Wall"])
	assert_that(parsed.legend["P"]).is_equal(["Player"])
	assert_that(parsed.legend["*"]).is_equal(["Crate"])
	assert_that(parsed.legend["@"]).is_equal(["Crate", "Target"])
	assert_that(parsed.legend["O"]).is_equal(["Target"])
	assert_that(parsed.legend["X"]).is_equal(["Crate", "Player"])

func test_sounds() -> void:
	assert_dict(parsed).contains_keys(["sounds"])
	assert_that(parsed.sounds).is_equal([
		# perhaps a map? I'm sure there are lots of cases/other names
		["Crate", "move", "36772507"]
		])

func test_collision_layers() -> void:
	assert_dict(parsed).contains_keys(["collisionlayers"])
	assert_that(parsed.collisionlayers).is_equal([
		["Background"],
		["Target"],
		["Player", "Wall", "Crate"],
		])

func test_rules() -> void:
	assert_dict(parsed).contains_keys(["rules"])
	assert_that(parsed.rules).is_equal([{
			pattern=[[">", "Player"], ["Crate"]],
			update=[[">", "Player"], [">", "Crate"]]
			}, {
			pattern=["DOWN", [">", "Player"], ["Crate"]],
			update=[[">", "Player"], [">", "Crate"]]
			}
		])

func test_winconditions() -> void:
	assert_dict(parsed).contains_keys(["winconditions"])
	assert_that(parsed.winconditions).is_equal([["all", "Target", "on", "Crate"]])


func test_puzzles() -> void:
	assert_dict(parsed).contains_keys(["puzzles"])
	assert_that(len(parsed.puzzles)).is_equal(3)

func test_level_first() -> void:
	assert_that(parsed.puzzles[0].shape).is_equal([
		["#", "#", "#", "#", null, null],
		["#", null, "O", "#", null, null],
		["#", null, null, "#", "#", "#"],
		["#", "@", "P", null, null, "#"],
		["#", null, null, "*", null, "#"],
		["#", null, null, "#", "#", "#"],
		["#", "#", "#", "#", null, null],
		])

func test_level_second() -> void:
	assert_that(parsed.puzzles[1].meta.message).is_equal("level 2 begins")
	assert_that(parsed.puzzles[1].shape).is_equal([
		["#", "#", "#", "#", "#", "#"],
		["#", null, null, null, null, "#"],
		["#", null, "#", "P", null, "#"],
		["#", null, "*", "@", null, "#"],
		["#", null, "O", "@", null, "#"],
		["#", null, null, null, null, "#"],
		["#", "#", "#", "#", "#", "#"],
		])

func test_level_final() -> void:
	assert_that(parsed.puzzles[2].meta.message).is_equal("game complete!")
	assert_that(parsed.puzzles[2].shape).is_null()
