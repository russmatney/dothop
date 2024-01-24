@tool
extends Object
class_name DHData


enum dotType { Dot, Dotted, Goal}

static var puzzle_group = "dothop_puzzle"
static var reset_hold_t = 0.4

static var hud_scene = "res://src/hud/DotHopHUD.tscn"


static func save_game(tree):
	pass

static func load_game(tree):
	pass


# Returns puzzle instances for the current savegame
static func get_puzzle_sets():
	pass
