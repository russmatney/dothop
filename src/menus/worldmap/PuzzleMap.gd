@tool
extends Node2D

## props ##################################################

@onready var in_editor = Engine.is_editor_hint()
@onready var puzzle_sets = Store.get_puzzle_sets()
@onready var ps_maps: Array[PSMap]

class PSMap:
	var puzzle_set: PuzzleSet
	var width: float
	var height: float

	var pos: Vector2
	var size: Vector2

	func _init(ps):
		puzzle_set = ps
		width = 0
		height = 0

		for level in puzzle_set.get_game_def().levels:
			width += float(level.width)
			height += float(level.height)

## ready ##################################################

func _ready():
	Log.pr("analyzing puzzle_sets", len(puzzle_sets))

	ps_maps = []
	for ps in puzzle_sets:
		# Log.pr("Solving....")
		# ps.get_analyzed_game_def()
		ps_maps.append(PSMap.new(ps))
	Log.pr("Built puzzle maps.")

	render()

## render ##################################################

func render():
	U.remove_children(self)

	var acc_x = 0
	var acc_y = 0
	for psmap in ps_maps:
		psmap.size = Vector2(psmap.width, psmap.height)
		psmap.pos = Vector2(acc_x, acc_y) - Vector2(psmap.size.x / 2, 0)

		var color = U.rand_of([Color.CRIMSON, Color.PERU, Color.AQUA])
		var rect = U.add_color_rect(self, psmap.pos, psmap.size, color, true)
		rect.ready.connect(func(): rect.set_owner(self))

		# acc_x += psmap.width
		acc_y += psmap.height
