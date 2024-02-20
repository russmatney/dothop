extends GdUnitTestSuite

# TODO restore dothop hud tests

var game

func before_all():
	game = load("res://src/puzzle/GameScene.tscn").instantiate()
	add_child(game)

func after_all():
	game.free()

