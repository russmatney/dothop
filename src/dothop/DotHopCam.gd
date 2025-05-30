extends Camera2D
class_name DotHopCam

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
