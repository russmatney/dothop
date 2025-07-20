@tool
extends WorldMap

## props ##################################################

@onready var in_editor: bool = Engine.is_editor_hint()
@onready var worlds: Array = Store.get_worlds()
@onready var world_maps: Array[PSMap]

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
	world_maps = []
	for world: PuzzleWorld in worlds:
		world_maps.append(PSMap.new(world))

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
	for world_map: PSMap in world_maps:
		Log.pr("getting worldmap texture", world_map)
		var worldmap_island: Texture2D = world_map.world.get_worldmap_island_texture()

		world_map.size = worldmap_island.get_size()
		world_map.pos = Vector2(acc_x, acc_y)

		acc_x += world_map.size.x + x_buffer
		acc_y += world_map.size.y + y_buffer

		# create world node
		var world: Node2D = Node2D.new()
		world.position = world_map.pos
		world.ready.connect(func() -> void:
			world.set_owner(self)
			world.add_to_group(gen_key, true))
		map.add_child(world)

		# worldmap island texture
		var texture_rect: TextureRect = TextureRect.new()
		texture_rect.set_texture(worldmap_island)
		texture_rect.position = world_map.pos
		texture_rect.ready.connect(func() -> void:
			texture_rect.set_owner(self)
			texture_rect.add_to_group(gen_key, true))
		map.add_child(texture_rect)

		# create marker
		var marker: PuzzleMapMarker = PuzzleMapMarker.new()
		marker.world = world_map.world
		marker.position = world_map.center()
		marker.ready.connect(func() -> void:
			marker.set_owner(self)
			marker.add_to_group(gen_key, true))
		add_child(marker)
