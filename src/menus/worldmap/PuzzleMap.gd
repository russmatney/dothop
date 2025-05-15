@tool
extends WorldMap

## props ##################################################

@onready var in_editor: bool = Engine.is_editor_hint()
@onready var puzzle_sets: Array = Store.get_puzzle_sets()
@onready var ps_maps: Array[PSMap]

@export var x_buffer: float = 48
@export var y_buffer: float = 24

class PSMap:
	var puzzle_set: PuzzleSet
	var pos: Vector2
	var size: Vector2

	func _init(ps: PuzzleSet) -> void:
		puzzle_set = ps

	func center() -> Vector2:
		return pos + (size / 2)

	func to_pretty() -> Variant:
		return {ps=puzzle_set, pos=pos, size=size}

## ready ##################################################

func _ready() -> void:
	Log.info("analyzing puzzle_sets", len(puzzle_sets))

	ps_maps = []
	for ps: PuzzleSet in puzzle_sets:
		ps_maps.append(PSMap.new(ps))
	Log.info("Built puzzle maps.")

	render()

## render ##################################################

const gen_key: String = "puzzlemap_generated"
func render() -> void:
	# TODO maybe find all in this group and remove them that way?
	U.remove_children(self, {filter=func(ch: Node) -> void:
		return ch.is_in_group(gen_key)})
	U.remove_children(map, {filter=func(ch: Node) -> void:
		return ch.is_in_group(gen_key)})

	Log.info("Removed previously generated nodes")

	var acc_x: float = 0
	var acc_y: float = 0
	Log.info("Building psmaps:", ps_maps)
	for psmap: PSMap in ps_maps:
		Log.info("Building map for psmap:", psmap)
		var worldmap_island: Texture2D = psmap.puzzle_set.get_worldmap_island_texture()

		psmap.size = worldmap_island.get_size()
		psmap.pos = Vector2(acc_x, acc_y)

		acc_x += psmap.size.x + x_buffer
		acc_y += psmap.size.y + y_buffer

		# create world node
		var world: Node2D = Node2D.new()
		world.position = psmap.pos
		world.ready.connect(func() -> void:
			world.set_owner(self)
			world.add_to_group(gen_key, true))
		map.add_child(world)

		# worldmap island texture
		var texture_rect: TextureRect = TextureRect.new()
		texture_rect.set_texture(worldmap_island)
		texture_rect.position = psmap.pos
		texture_rect.ready.connect(func() -> void:
			texture_rect.set_owner(self)
			texture_rect.add_to_group(gen_key, true))
		map.add_child(texture_rect)

		# create marker
		var marker: PuzzleMapMarker = PuzzleMapMarker.new()
		marker.puzzle_set = psmap.puzzle_set
		marker.position = psmap.center()
		marker.ready.connect(func() -> void:
			marker.set_owner(self)
			marker.add_to_group(gen_key, true))
		add_child(marker)

		Log.info("built map for psmap:", psmap)
