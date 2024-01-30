extends GdUnitTestSuite
class_name GameDefTest

func test_expected_level_count():
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
LEVELS
=======

.....
xooot
.....

o..o.o.
ox.o.ot
...o.o.
.......

"}) # note the extra empty line! ^

	assert_int(len(parsed.levels)).is_equal(2)
