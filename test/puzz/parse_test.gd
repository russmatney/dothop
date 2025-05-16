extends GdUnitTestSuite

func parse() -> ParsedGame:
	var path := "res://test/puzz/simple_block_pushing_game.ps"
	return GameDef.parse_game_def(path).parsed

var parsed: ParsedGame

func before() -> void:
	parsed = parse()

func test_prelude() -> void:
	assert_that(parsed.prelude.title).is_equal("Simple Block Pushing Game")
	assert_that(parsed.prelude.author).is_equal("David Skinner")
	assert_that(parsed.prelude.homepage).is_equal("www.puzzlescript.net")
	assert_that(parsed.prelude.debug).is_equal(true)

func test_legend() -> void:
	# add coverage for 'and' vs 'or'
	assert_that(parsed.legend["."]).is_equal(["Background"])
	assert_that(parsed.legend["#"]).is_equal(["Wall"])
	assert_that(parsed.legend["P"]).is_equal(["Player"])
	assert_that(parsed.legend["*"]).is_equal(["Crate"])
	assert_that(parsed.legend["@"]).is_equal(["Crate", "Target"])
	assert_that(parsed.legend["O"]).is_equal(["Target"])
	assert_that(parsed.legend["X"]).is_equal(["Crate", "Player"])

func test_puzzles() -> void:
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
