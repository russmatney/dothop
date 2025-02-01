extends GdUnitTestSuite
class_name GameDefTest

func test_expected_puzzle_count() -> void:
	var parsed: GameDef = Puzz.parse_game_def(null, {contents="
title DotHop
author Russell Matney

=======
LEGEND
=======

. = Background
a = Player
o = Dot
t = Goal

x = Player and Dotted

=======
PUZZLES
=======

.....
xooot
.....

o..o.o.
ox.o.ot
...o.o.
.......

"}) # note the extra empty line! ^

	assert_int(len(parsed.puzzles)).is_equal(2)

func test_puzzle_def_metadata() -> void:
	var parsed: GameDef= Puzz.parse_game_def(null, {contents="
title DotHop
author Russell Matney

=======
LEGEND
=======

. = Background
a = Player
o = Dot
t = Goal

x = Player and Dotted

=======
PUZZLES
=======

first
name First puzzle
message Good luck out there | You got this!

.....
xooot
.....

o.o...
oxo.t.
......

post_message Puzzle complete!
post_message_body That was an easy one | Congrats, Nerd.

o..o.o.
ox.o.ot
...o.o.
.......
"})
	assert_int(len(parsed.puzzles)).is_equal(3)
	var puzz_one: PuzzleDef = parsed.puzzles[0]
	var puzz_two: PuzzleDef = parsed.puzzles[1]
	var puzz_three: PuzzleDef = parsed.puzzles[2]

	assert_bool(puzz_one.meta.first).is_true()
	assert_that(puzz_one.meta.name).is_equal("First puzzle")
	assert_that(puzz_one.meta.message).is_equal("Good luck out there | You got this!")

	assert_that(puzz_two.meta).is_equal({})

	assert_that(puzz_three.meta.post_message).is_equal("Puzzle complete!")
	assert_that(puzz_three.meta.post_message_body).is_equal("That was an easy one | Congrats, Nerd.")
