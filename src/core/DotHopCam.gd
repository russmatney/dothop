extends Camera2D
class_name DotHopCam

## static #####################################################################

static var dhcam_scene: String = "res://src/core/DotHopCam.tscn"

static func ensure_camera(node: Node) -> DotHopCam:
	var dhcam: DotHopCam
	dhcam = node.get_node_or_null("DotHopCam")
	if dhcam == null:
		dhcam = node.get_parent().get_node_or_null("DotHopCam")
	if dhcam == null:
		var dhscene: PackedScene = load(dhcam_scene)
		dhcam = dhscene.instantiate()
		node.add_child(dhcam)
	return dhcam

## vars #####################################################################

var zoom_min: float = 0.5
var zoom_max: float = 5.0
var base_margin: float = 64

var puzzle_node: DotHopPuzzle

## enter tree #####################################################################

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		get_tree().node_added.connect(on_node_added)

func on_node_added(node: Node) -> void:
	if node is DotHopPuzzle:
		set_puzzle_node(node as DotHopPuzzle)

## ready #####################################################################

func _ready() -> void:
	if puzzle_node == null:
		for n: Variant in get_parent().get_children():
			if n is DotHopPuzzle:
				puzzle_node = n
				break

	if puzzle_node:
		set_puzzle_node(puzzle_node)

## puzzle node handling #####################################################################

func set_puzzle_node(puzz: DotHopPuzzle) -> void:
	puzzle_node = puzz
	puzzle_node.rebuilt_nodes.connect(recenter_cam, CONNECT_DEFERRED)
	recenter_cam()

func recenter_cam() -> void:
	if puzzle_node == null:
		return

	var rect := puzzle_node.puzzle_rect()
	if rect != Rect2():
		center_on_rect(rect)

func center_on_rect(rect: Rect2) -> void:
	rect = rect.grow(base_margin)

	var viewport_rect: Rect2 = get_viewport_rect()
	var screen_size: Vector2 = viewport_rect.size
	if rect.size.x > rect.size.y * screen_size.aspect():
		zoom = clamp(screen_size.x / rect.size.x, zoom_min, zoom_max) * Vector2.ONE
	else:
		zoom = clamp(screen_size.y / rect.size.y, zoom_min, zoom_max) * Vector2.ONE

	global_position = rect.get_center()
