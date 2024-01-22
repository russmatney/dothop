@tool
extends Node2D

@onready var map = $%MapSprite

@export var current_marker: Marker2D = null :
	set(marker):
		current_marker = marker
		center_map()

func center_map():
	var pos = Vector2(0, 0)
	if current_marker != null:
		pos = current_marker.position * -1

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
