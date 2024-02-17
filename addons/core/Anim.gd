@tool
extends Object
class_name Anim

# dot intro/outros

static func slide_in(node, t=0.6):
	var og_position = node.position
	# jump + shrink to starting position :/
	node.position = node.position - Vector2.ONE * 10
	node.scale = Vector2.ONE * 0.5
	var tween = node.create_tween()
	tween.tween_property(node, "scale", Vector2.ONE, t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "position", og_position, t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

static func slide_out(node, t=0.6):
	var target_position = node.position - Vector2.ONE * 10
	var tween = node.create_tween()
	tween.tween_property(node, "scale", Vector2.ONE * 0.5, t)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "position", target_position, t)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "modulate:a", 0.0, t)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# helper

static func tween_on_node(node, tween_name):
	if tween_name in node:
		# var tween = node[tween_name]
		# if tween != null:
		# 	tween.kill()
		node[tween_name] = node.create_tween()
		return node[tween_name]
	else:
		return node.create_tween()

# move

static func move_to_coord(node, coord, t, trans=Tween.TRANS_QUAD, ease=Tween.EASE_IN):
	var target_pos = coord * node.square_size
	var tween = tween_on_node(node, "move_tween")
	tween.tween_property(node, "position", target_pos, t)\
		.set_trans(trans).set_ease(ease)

static func move_attempt_pull_back(node, target_position, t):
	var tween = tween_on_node(node, "move_tween")
	tween.tween_property(node, "position", target_position, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position", node.position, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# Scales

static func scale_up_down_up(node, t):
	var tween = tween_on_node(node, "scale_tween")
	tween = node.create_tween()
	tween.tween_property(node, "scale", 1.3*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", 0.8*Vector2.ONE, t/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", 1.0*Vector2.ONE, t/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

static func scale_down_up(node, t):
	var tween = tween_on_node(node, "scale_tween")
	tween = node.create_tween()
	tween.tween_property(node, "scale", 0.8*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", 1.0*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

static func scale_up_down(node, t):
	var tween = tween_on_node(node, "scale_tween")
	tween = node.create_tween()
	tween.tween_property(node, "scale", 1.3*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", 1.0*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# Hops

static func hop_to_coord(node, coord, t):
	move_to_coord(node, coord, t)
	scale_up_down_up(node, t)

static func hop_back(node, coord, t):
	move_to_coord(node, coord, t, Tween.TRANS_CUBIC, Tween.EASE_IN)
	scale_down_up(node, t)

static func hop_attempt_pull_back(node, og_position, target_position, t=0.4):
	move_attempt_pull_back(node, target_position, t)
	scale_up_down(node, t)
