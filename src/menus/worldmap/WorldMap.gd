@tool
extends Node2D
class_name WorldMap

@onready var map = $%MapSprite

@export var current_marker: Marker2D = null :
	set(marker):
		current_marker = marker
		center_map()

func center_map():
	var pos = Vector2(0, 0)
	if current_marker != null:
		pos = current_marker.position * -1

	if Engine.is_editor_hint():
		return

	var t = create_tween()
	t.tween_property(map, "position", pos, 0.4)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN_OUT)

	if pos == Vector2(0, 0):
		t.parallel().tween_property(self, "scale", Vector2.ONE, 0.4)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_IN_OUT)
	else:
		t.parallel().tween_property(self, "scale", Vector2.ONE * 2.0, 0.4)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_IN_OUT)

# Returns an array of puzzle map markers
# does not include markers without assigned puzzle_sets
func get_markers():
	var ms = []
	for ch in get_children():
		if ch is PuzzleMapMarker and ch.puzzle_set != null:
			ms.append(ch)
	return ms
