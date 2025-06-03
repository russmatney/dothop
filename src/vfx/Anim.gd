@tool
extends Object
class_name Anim

# dot intro/outros
# NOTE node.current_position() is preferred to get the node's coord-position when available

static func slide_in(node: Node2D, dist: float = 10, t: float = 0.6) -> void:
	var og_position: Vector2 = node.call("current_position") if node.has_method("current_position") else node.position
	# jump + shrink to starting position :/
	node.position = node.position - Vector2.ONE * dist
	node.scale = Vector2.ONE * 0.5
	var tween: Tween = node.create_tween()
	tween.tween_property(node, "scale", Vector2.ONE, t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "position", og_position, t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

static func slide_out(node: Node2D, t: float = 0.6) -> void:
	var og_position: Vector2 = node.call("current_position") if node.has_method("current_position") else node.position
	var target_position: Vector2 = og_position - Vector2.ONE * 10
	var tween: Tween = node.create_tween()
	tween.tween_property(node, "scale", Vector2.ONE * 0.5, t)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "position", target_position, t)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "modulate:a", 0.0, t)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

static func slide_from_point(node: Node2D, pos: Vector2 = Vector2.ZERO, t: float = 0.6, delay_ts: Array = []) -> void:
	var delay_t: float = U.rand_of(delay_ts) if len(delay_ts) > 0 else 0.0
	var og_position: Vector2 = node.call("current_position") if node.has_method("current_position") else node.position
	# jump + shrink to starting position :/
	node.position = pos
	node.scale = Vector2.ONE * 0.5
	node.modulate.a = 0.5

	var tween: Tween = node.create_tween()
	if delay_t:
		tween.tween_interval(delay_t)
	tween.tween_property(node, "scale", Vector2.ONE, t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "position", og_position, t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "modulate:a", 1.0, t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

static func slide_to_point(node: CanvasItem, target_position: Vector2 = Vector2.ZERO, t: float = 0.6, delay_ts: Array = []) -> void:
	var delay_t: float = U.rand_of(delay_ts) if len(delay_ts) > 0 else 0.0
	var tween: Tween = node.create_tween()
	if delay_t:
		tween.tween_interval(delay_t)
	tween.tween_property(node, "scale", Vector2.ONE * 0.5, t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(node, "position", target_position, t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(node, "modulate:a", 0.0, t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

# helper

static func tween_on_node(node: CanvasItem, tween_name: String) -> Tween:
	if tween_name in node:
		# TODO maybe kill/clear existing tweens
		node[tween_name] = node.create_tween()
		return node[tween_name]
	else:
		return node.create_tween()

# move

static func move_to_coord(node: CanvasItem, coord: Vector2, t: float, trans: Tween.TransitionType = Tween.TRANS_CUBIC, _ease: Tween.EaseType = Tween.EASE_OUT) -> void:
	var target_pos: Vector2 = coord * node.get("square_size")
	var tween: Tween = tween_on_node(node, "move_tween")
	tween.tween_property(node, "position", target_pos, t).set_trans(trans).set_ease(_ease)

static func move_attempt_pull_back(node: CanvasItem, og_position: Vector2, target_position: Vector2, t: float) -> void:
	var tween: Tween = tween_on_node(node, "move_tween")
	tween.tween_property(node, "position", target_position, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position", og_position, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

static func float_a_bit(node: CanvasItem, og_position: Vector2, t: float = 0.8,
	trans: Tween.TransitionType = Tween.TRANS_QUAD,
	_ease: Tween.EaseType = Tween.EASE_IN
	) -> void:
	var tween: Tween = tween_on_node(node, "float_tween")
	var dist: float = randfn(1.0, 1.5)
	var dir: Vector2 = Vector2(randfn(0.0, 1.0), randfn(0.0, 1.0)).normalized()
	var offset: Vector2 = dir * dist
	tween.tween_property(node, "position", og_position + offset, t).set_trans(trans).set_ease(_ease)
	# tween.tween_interval(t/2)
	# tween.tween_property(node, "position", og_position, t).set_trans(trans).set_ease(_ease)
	# tween.tween_interval(t/3)
	tween.tween_callback(Anim.float_a_bit.bind(node, og_position, t, trans, _ease))

# Scales

static func scale_up_down_up(node: CanvasItem, t: float) -> void:
	var tween: Tween = tween_on_node(node, "scale_tween")
	tween.tween_property(node, "scale", 1.3*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", 0.8*Vector2.ONE, t/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", 1.0*Vector2.ONE, t/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

static func scale_down_up(node: CanvasItem, t: float) -> void:
	var tween: Tween = tween_on_node(node, "scale_tween")
	tween.tween_property(node, "scale", 0.8*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", 1.0*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

static func scale_up_down(node: CanvasItem, t: float) -> void:
	var tween: Tween = tween_on_node(node, "scale_tween")
	tween.tween_property(node, "scale", 1.3*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", 1.0*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# Hops

static func hop_to_coord(node: CanvasItem, coord: Vector2, t: float) -> void:
	move_to_coord(node, coord, t)
	scale_up_down_up(node, t)

static func hop_back(node: CanvasItem, coord: Vector2, t: float) -> void:
	move_to_coord(node, coord, t, Tween.TRANS_CUBIC, Tween.EASE_IN)
	scale_down_up(node, t)

static func hop_attempt_pull_back(node: CanvasItem, og_position: Vector2, target_position: Vector2, t: float = 0.4) -> void:
	move_attempt_pull_back(node, og_position, target_position, t)
	scale_up_down(node, t)

# fade

static func fade_in(node: CanvasItem, t: float = 0.5) -> void:
	var tween: Tween = tween_on_node(node, "fade_tween")
	tween.tween_property(node, "modulate:a", 1.0, t).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

static func fade_out(node: CanvasItem, t: float = 0.5) -> void:
	var tween: Tween = tween_on_node(node, "fade_tween")
	tween.tween_property(node, "modulate:a", 0.0, t).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

## puzzle_node ###########################################################

static func puzzle_animate_intro_from_point(puzz_node: DotHopPuzzle, min_t := 0.1, max_t := 1.4) -> Signal:
	var t: float = 0.6
	var puzz_rect: Rect2 = puzz_node.puzzle_rect()

	var positions: Array = [
		puzz_rect.get_center(),
		# puzz_node.state.players[0].node.get_global_position()
		]
	var nodes: Array = []
	nodes.append_array((puzz_node.state.players as Array).map(
		func (p: DotHopPuzzle.Player) -> Node2D: return p.node))
	nodes.append_array(puzz_node.all_cell_nodes())

	for node: Node2D in nodes:
		node.modulate.a = 0.0

	var log_min_t := log(min_t)
	var log_max_t := log(max_t)
	var step := (log_max_t-log_min_t)/len(nodes)

	for i: int in range(len(nodes)):
		var delay: float = exp(log_min_t + i * step)
		var node: Node2D = nodes[i]
		Anim.slide_from_point(node, U.rand_of(positions) as Vector2, t, [delay])

	return puzz_node.get_tree().create_timer(t).timeout

static func puzzle_animate_outro_to_point(puzz_node: DotHopPuzzle) -> Signal:
	var t: float = 0.6
	var puzz_rect: Rect2 = puzz_node.puzzle_rect()

	var positions: Array = [
		puzz_rect.get_center(),
		# puzz_node.state.players[0].node.get_global_position()
		]

	var nodes: Array = []
	nodes.append_array((puzz_node.state.players as Array).map(func (p: DotHopPuzzle.Player) -> Node2D: return p.node))
	nodes.append_array(puzz_node.all_cell_nodes())

	for node: Node2D in nodes:
		var delays: Array = []
		if U.rand_of([true, false, false, false]):
			delays.append(0.05)
		Anim.slide_to_point(node, U.rand_of(positions) as Vector2, t, delays)

	return puzz_node.get_tree().create_timer(t).timeout

## toast ###########################################################

static func toast(node: Control, opts: Dictionary = {}) -> void:
	if opts.get("wait_frame", false):
		node.set_visible(false)
		await node.get_tree().process_frame

	var screen_rect: Rect2 = node.get_viewport_rect()
	var margin: float = opts.get("margin", 20)
	var target_pos: Vector2 = screen_rect.end - node.get_size() - Vector2.ONE * margin
	var initial_pos: Vector2 = Vector2(target_pos.x, screen_rect.size.y)
	var in_t: float = opts.get("in_t", 0.7)
	var out_t: float = opts.get("out_t", 0.7)
	var delay_t: float = opts.get("delay_t", 1.0)

	node.global_position = initial_pos
	node.set_visible(true)

	var t: Tween = node.create_tween()
	t.tween_property(node, "global_position", target_pos, in_t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	t.tween_property(node, "global_position", initial_pos, out_t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)\
		.set_delay(delay_t)

	if opts.get("free_node", true):
		t.tween_callback(node.queue_free)
