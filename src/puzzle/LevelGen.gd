@tool
extends Node2D

#####################################################################
## vars

@export_file var puzz_file: String
@export var square_size: int = 64
@export var level_num: int = 0

var game_def

#####################################################################
## ready

func _ready():
	game_def = Puzz.parse_game_def(puzz_file)
	Log.pr("Found", len(game_def.levels), "levels")

	generate_level(level_num)

#####################################################################
## generate level

func generate_level(num=0):
	var level_node_name = "Level_%s" % num
	for ch in get_children():
		if ch.name == level_node_name:
			ch.free()

	var node = DotHopPuzzle.build_puzzle_node({game_def=game_def, puzzle_num=num})
	if node == null:
		Log.warn("No node generated for level num", num)
		return
	node.name = level_node_name
	node.win.connect(func():
		node.queue_free()
		load_next(num + 1))
	node.square_size = square_size
	add_child(node)
	node.set_owner(self)

#####################################################################
## load next

func load_next(next_num):
	if next_num < len(game_def.levels):
		generate_level(next_num)
	else:
		Log.pr("win all!")