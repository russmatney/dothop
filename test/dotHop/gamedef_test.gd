extends GdUnitTestSuite
class_name GameDefTest

func test_level_counts():
	# TODO these are unnecessarily hard-coded - should move to a more reasonable pattern,
	# especially so these numbers can move around

	var one = DotHopPuzzle.build_puzzle_node({game_def_path="res://src/puzzles/dothop-one.txt"})
	assert_int(len(one.game_def.levels)).is_equal(4)

	var two = DotHopPuzzle.build_puzzle_node({game_def_path="res://src/puzzles/dothop-two.txt"})
	assert_int(len(two.game_def.levels)).is_equal(12)

	var three = DotHopPuzzle.build_puzzle_node({game_def_path="res://src/puzzles/dothop-three.txt"})
	assert_int(len(three.game_def.levels)).is_equal(10)

	var four = DotHopPuzzle.build_puzzle_node({game_def_path="res://src/puzzles/dothop-four.txt"})
	assert_int(len(four.game_def.levels)).is_equal(3)

	var five = DotHopPuzzle.build_puzzle_node({game_def_path="res://src/puzzles/dothop-five.txt"})
	assert_int(len(five.game_def.levels)).is_equal(3)

	var six = DotHopPuzzle.build_puzzle_node({game_def_path="res://src/puzzles/dothop-six.txt"})
	assert_int(len(six.game_def.levels)).is_equal(3)

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

.......
.xooot.
.......

o..o.o.
ox.o.ot
...o.o.
.......

"}) # note the extra empty line! ^

	assert_int(len(parsed.levels)).is_equal(2)
