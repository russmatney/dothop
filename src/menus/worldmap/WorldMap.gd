@tool
extends Node2D
class_name WorldMap

@onready var map: Node2D = $%MapSprite

@export var current_marker: Marker2D = null :
	set(marker):
		current_marker = marker
		if is_node_ready():
			center_map()

@export var zoom_scale_min: float = 1.0
@export var zoom_scale_max: float = 2.0

func center_map() -> void:
	var pos: Vector2 = Vector2(0, 0)
	if current_marker != null:
		pos = current_marker.position * -1

	if Engine.is_editor_hint():
		return

	var t: Tween = create_tween()
	t.tween_property(map, "position", pos, 0.4)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN_OUT)

	if pos == Vector2(0, 0):
		t.parallel().tween_property(self, "scale", Vector2.ONE * zoom_scale_min, 0.4)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_IN_OUT)
	else:
		t.parallel().tween_property(self, "scale", Vector2.ONE * zoom_scale_min, 0.1)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_IN_OUT)
		t.parallel().tween_property(self, "scale", Vector2.ONE * zoom_scale_max, 0.4)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_IN_OUT)\
			.set_delay(0.1)

# Returns an array of puzzle map markers
# does not include markers without assigned worlds
func get_markers() -> Array:
	var ms: Array = []
	for ch: Node in get_children():
		if ch is PuzzleMapMarker and (ch as PuzzleMapMarker).world != null:
			ms.append(ch)
	return ms
