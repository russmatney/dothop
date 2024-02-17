@tool
extends Object
class_name Anim

static func slide_in(node, t=0.8):
	var og_position = node.position
	# jump + shrink to starting position :/
	node.position = node.position - Vector2.ONE * 10
	node.scale = Vector2.ONE * 0.5
	var tween = node.create_tween()
	tween.tween_property(node, "scale", Vector2.ONE, t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "position", og_position, t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

static func slide_out(node, t=0.8):
	var target_position = node.position - Vector2.ONE * 10
	var tween = node.create_tween()
	tween.tween_property(node, "scale", Vector2.ONE * 0.5, t)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "position", target_position, t)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "modulate:a", 0.0, t)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
