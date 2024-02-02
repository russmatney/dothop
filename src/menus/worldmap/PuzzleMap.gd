@tool
extends WorldMap

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

	func center():
		return pos + (size / 2)

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

const gen_key = "puzzlemap_generated"
func render():
	U.remove_children(self, {filter=func(ch):
		return ch.is_in_group(gen_key)})
	U.remove_children(map, {filter=func(ch):
		return ch.is_in_group(gen_key)})

	var acc_x = 0
	var acc_y = 0
	var last_color
	for psmap in ps_maps:
		psmap.size = Vector2(psmap.width, psmap.height)
		psmap.pos = Vector2(acc_x, acc_y) - Vector2(psmap.size.x / 2, 0)

		# acc_x += psmap.width
		acc_y += psmap.height

		# create rect
		var color = U.rand_of([Color.CRIMSON, Color.PERU, Color.AQUA, Color.LIME]\
			.filter(func(x): return x != last_color))
		last_color = color
		var rect = U.add_color_rect(map, psmap.pos, psmap.size, color, true)
		rect.ready.connect(func():
			rect.set_owner(self)
			rect.add_to_group(gen_key, true))

		render_children(psmap, rect)

		# add icon
		var icon = psmap.puzzle_set.get_icon_texture()
		var texture_rect = TextureRect.new()
		texture_rect.set_texture(icon)
		texture_rect.position = psmap.center() - Vector2(16, 16)
		texture_rect.z_index = 2
		texture_rect.ready.connect(func():
			texture_rect.set_owner(self)
			texture_rect.add_to_group(gen_key, true))
		map.add_child(texture_rect)


		# create marker
		var marker = PuzzleMapMarker.new()
		marker.puzzle_set = psmap.puzzle_set
		marker.position = psmap.center()
		marker.ready.connect(func():
			marker.set_owner(self)
			marker.add_to_group(gen_key, true))
		add_child(marker)

func render_children(psmap, node):
	var acc_x = 0
	var acc_y = 0
	var last_color

	for level_def in psmap.puzzle_set.get_puzzles():
		# Log.pr("level_def", level_def.idx)

		var size = Vector2(level_def.width, level_def.height)
		var pos = Vector2(acc_x, acc_y) - Vector2(size.x / 2, 0)

		var color = U.rand_of([Color.CRIMSON, Color.PERU, Color.AQUA, Color.LIME]\
			.filter(func(x): return x != last_color))
		last_color = color
		var rect = U.add_color_rect(node, pos, size, color, true)
		rect.ready.connect(func():
			rect.set_owner(self)
			rect.add_to_group(gen_key, true))

		acc_x += level_def.width
		acc_y += level_def.height
