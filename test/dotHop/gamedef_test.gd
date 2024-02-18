extends GdUnitTestSuite
class_name GameDefTest

func test_expected_puzzle_count():
	var parsed = Puzz.parse_game_def(null, {contents="
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

func test_puzzle_def_metadata():
	var parsed = Puzz.parse_game_def(null, {contents="
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

post_message Puzzle complete!
post_message_body That was an easy one | Congrats, Nerd.

o..o.o.
ox.o.ot
...o.o.
.......

"}) # note the extra empty line! ^

	# TODO rewrite these tests
	assert_int(len(parsed.puzzles)).is_equal(2)
