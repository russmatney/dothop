extends Camera2D
class_name DotHopCam

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

var zoom_min: float = 0.5
var zoom_max: float = 5.0
var base_margin: float = 64

func center_on_rect(rect: Rect2) -> void:
	rect = rect.grow(base_margin)

	var screen_size: Vector2 = get_viewport_rect().size
	if rect.size.x > rect.size.y * screen_size.aspect():
		zoom = clamp(screen_size.x / rect.size.x, zoom_min, zoom_max) * Vector2.ONE
	else:
		zoom = clamp(screen_size.y / rect.size.y, zoom_min, zoom_max) * Vector2.ONE

	global_position = rect.get_center()

