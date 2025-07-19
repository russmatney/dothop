@tool
extends WorldMap

## props ##################################################

@onready var in_editor: bool = Engine.is_editor_hint()
@onready var worlds: Array = Store.get_worlds()
@onready var ps_maps: Array[PSMap]

@export var x_buffer: float = 48
@export var y_buffer: float = 24

class PSMap:
	var world: PuzzleWorld
	var pos: Vector2
	var size: Vector2

	func _init(ps: PuzzleWorld) -> void:
		world = ps

	func center() -> Vector2:
		return pos + (size / 2)

	func to_pretty() -> Variant:
		return {ps=world, pos=pos, size=size}

## ready ##################################################

func _ready() -> void:
	ps_maps = []
	for ps: PuzzleWorld in worlds:
		ps_maps.append(PSMap.new(ps))

	render()


## render ##################################################

const gen_key: String = "puzzlemap_generated"
func render() -> void:
	# TODO maybe find all in this group and remove them that way?
	U.remove_children(self, {filter=func(ch: Node) -> void:
		return ch.is_in_group(gen_key)})
	U.remove_children(map, {filter=func(ch: Node) -> void:
		return ch.is_in_group(gen_key)})

	var acc_x: float = 0
	var acc_y: float = 0
	for psmap: PSMap in ps_maps:
		var worldmap_island: Texture2D = psmap.world.get_worldmap_island_texture()

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
		marker.world = psmap.world
		marker.position = psmap.center()
		marker.ready.connect(func() -> void:
			marker.set_owner(self)
			marker.add_to_group(gen_key, true))
		add_child(marker)
