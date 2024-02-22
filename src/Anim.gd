@tool
extends Object
class_name Anim

# dot intro/outros
# NOTE node.current_position() is preferred to get the node's coord-position when available

static func slide_in(node, dist=10, t=0.6):
	var og_position = node.current_position() if node.has_method("current_position") else node.position
	# jump + shrink to starting position :/
	node.position = node.position - Vector2.ONE * dist
	node.scale = Vector2.ONE * 0.5
	var tween = node.create_tween()
	tween.tween_property(node, "scale", Vector2.ONE, t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "position", og_position, t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

static func slide_out(node, t=0.6):
	var og_position = node.current_position() if node.has_method("current_position") else node.position
	var target_position = og_position - Vector2.ONE * 10
	var tween = node.create_tween()
	tween.tween_property(node, "scale", Vector2.ONE * 0.5, t)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "position", target_position, t)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "modulate:a", 0.0, t)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

static func slide_from_point(node, pos=Vector2.ZERO, t=0.6, delay_ts=[]):
	var delay_t = U.rand_of(delay_ts)
	var og_position = node.current_position() if node.has_method("current_position") else node.position
	# jump + shrink to starting position :/
	node.position = pos
	node.scale = Vector2.ONE * 0.5
	node.modulate.a = 0.5

	var tween = node.create_tween()
	if delay_t:
		tween.tween_interval(delay_t)
	tween.tween_property(node, "scale", Vector2.ONE, t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "position", og_position, t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "modulate:a", 1.0, t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

static func slide_to_point(node, target_position=Vector2.ZERO, t=0.6, delay_ts=[]):
	var delay_t = U.rand_of(delay_ts)
	var tween = node.create_tween()
	if delay_t:
		tween.tween_interval(delay_t)
	tween.tween_property(node, "scale", Vector2.ONE * 0.5, t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(node, "position", target_position, t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(node, "modulate:a", 0.0, t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

# helper

static func tween_on_node(node, tween_name):
	if tween_name in node:
		node[tween_name] = node.create_tween()
		return node[tween_name]
	else:
		return node.create_tween()

# move

static func move_to_coord(node, coord, t, trans=Tween.TRANS_CUBIC, _ease=Tween.EASE_OUT):
	var target_pos = coord * node.square_size
	var tween = tween_on_node(node, "move_tween")
	tween.tween_property(node, "position", target_pos, t).set_trans(trans).set_ease(_ease)

static func move_attempt_pull_back(node, og_position, target_position, t):
	var tween = tween_on_node(node, "move_tween")
	tween.tween_property(node, "position", target_position, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position", og_position, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# Scales

static func scale_up_down_up(node, t):
	var tween = tween_on_node(node, "scale_tween")
	tween.tween_property(node, "scale", 1.3*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", 0.8*Vector2.ONE, t/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", 1.0*Vector2.ONE, t/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

static func scale_down_up(node, t):
	var tween = tween_on_node(node, "scale_tween")
	tween.tween_property(node, "scale", 0.8*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", 1.0*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

static func scale_up_down(node, t):
	var tween = tween_on_node(node, "scale_tween")
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
	move_attempt_pull_back(node, og_position, target_position, t)
	scale_up_down(node, t)

## puzzle_node ###########################################################

static func puzzle_animate_intro_from_point(puzz_node):
	var t = 0.6
	var puzz_rect = puzz_node.puzzle_rect()

	var positions = [
		puzz_rect.get_center(),
		# puzz_node.state.players[0].node.get_global_position()
		]
	var nodes = []
	nodes.append_array(puzz_node.state.players.map(func (p): return p.node))
	nodes.append_array(puzz_node.all_cell_nodes())

	for node in nodes:
		node.modulate.a = 0.0

	for node in nodes:
		var delays = []
		if U.rand_of([true, false, false, false]):
			delays.append(0.05)
		Anim.slide_from_point(node, U.rand_of(positions), t, delays)

	return puzz_node.get_tree().create_timer(t).timeout

static func puzzle_animate_outro_to_point(puzz_node):
	var t = 0.6
	var puzz_rect = puzz_node.puzzle_rect()

	var positions = [
		puzz_rect.get_center(),
		# puzz_node.state.players[0].node.get_global_position()
		]

	var nodes = []
	nodes.append_array(puzz_node.state.players.map(func (p): return p.node))
	nodes.append_array(puzz_node.all_cell_nodes())

	for node in nodes:
		var delays = []
		if U.rand_of([true, false, false, false]):
			delays.append(0.05)
		Anim.slide_to_point(node, U.rand_of(positions), t, delays)

	return puzz_node.get_tree().create_timer(t).timeout

## toast ###########################################################

static func toast(node, opts={}):
	var screen_rect = node.get_viewport_rect()
	Log.pr("screen rect", screen_rect, "node size", node.get_size())
	var margin = opts.get("margin", 20)
	var target_pos = screen_rect.end - node.get_size() - Vector2.ONE * margin
	var initial_pos = Vector2(target_pos.x, screen_rect.size.y)
	var in_t = opts.get("in_t", 0.7)
	var out_t = opts.get("out_t", 0.7)
	var delay_t = opts.get("delay_t", 1.0)
	Log.pr("toasting the progress panel!", node, target_pos, initial_pos)

	node.global_position = initial_pos

	var t = node.create_tween()
	t.tween_property(node, "global_position", target_pos, in_t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	t.tween_property(node, "global_position", initial_pos, out_t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)\
		.set_delay(delay_t)
