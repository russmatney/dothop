@tool
extends WorldMap

## props ##################################################

@onready var in_editor = Engine.is_editor_hint()
@onready var puzzle_sets = Store.get_puzzle_sets()
@onready var ps_maps: Array[PSMap]

@export var x_buffer: float = 48
@export var y_buffer: float = 24

class PSMap:
	var puzzle_set: PuzzleSet
	var pos: Vector2
	var size: Vector2

	func _init(ps):
		puzzle_set = ps

	func center():
		return pos + (size / 2)

## ready ##################################################

func _ready():
	Log.pr("analyzing puzzle_sets", len(puzzle_sets))

	ps_maps = []
	for ps in puzzle_sets:
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
	for psmap in ps_maps:
		var worldmap_island = psmap.puzzle_set.get_worldmap_island_texture()

		psmap.size = worldmap_island.get_size()
		psmap.pos = Vector2(acc_x, acc_y)

		acc_x += psmap.size.x + x_buffer
		acc_y += psmap.size.y + y_buffer

		# create world node
		var world = Node2D.new()
		world.position = psmap.pos
		world.ready.connect(func():
			world.set_owner(self)
			world.add_to_group(gen_key, true))
		map.add_child(world)

		# worldmap island texture
		var texture_rect = TextureRect.new()
		texture_rect.set_texture(worldmap_island)
		texture_rect.position = psmap.pos
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
