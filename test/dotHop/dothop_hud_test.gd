extends GdUnitTestSuite

# TODO restore/rewrite dothop tests

var game

func before_all():
	game = load("res://src/puzzle/GameScene.tscn").instantiate()
	add_child(game)

func after_all():
	game.free()

