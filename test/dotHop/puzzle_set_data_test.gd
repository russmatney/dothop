extends GdUnitTestSuite
class_name PuzzleSetDataTest

################################################################
# parsers/constructors

func test_expected_puzzle_count() -> void:
	var psd: PuzzleSetData = PuzzleSetData.from_contents("
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

")

	assert_int(len(psd.puzzle_defs)).is_equal(2)
	assert_str(psd.display_name).is_equal("DotHop")

func test_puzzle_def_metadata() -> void:
	var psd: PuzzleSetData = PuzzleSetData.from_contents("
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
")
	assert_int(len(psd.puzzle_defs)).is_equal(3)
	var puzz_one: PuzzleDef = psd.puzzle_defs[0]
	var puzz_two: PuzzleDef = psd.puzzle_defs[1]
	var puzz_three: PuzzleDef = psd.puzzle_defs[2]

	assert_bool(puzz_one.meta.first).is_true()
	assert_that(puzz_one.meta.name).is_equal("First puzzle")
	assert_that(puzz_one.meta.message).is_equal("Good luck out there | You got this!")

	assert_that(puzz_two.meta).is_equal({})

	assert_that(puzz_three.meta.post_message).is_equal("Puzzle complete!")
	assert_that(puzz_three.meta.post_message_body).is_equal("That was an easy one | Congrats, Nerd.")

################################################################
