@tool
extends PhantomCamera2D
class_name DHPhantomCam

## enter tree #####################################################################

func _enter_tree() -> void:
	super._enter_tree()
	if not Engine.is_editor_hint():
		get_tree().node_added.connect(on_node_added)
		get_tree().node_removed.connect(on_node_removed)

func on_node_added(node: Node) -> void:
	if node is DotHopDot:
		add_follow_dot(node as DotHopDot)

func on_node_removed(node: Node) -> void:
	if node is DotHopDot:
		drop_follow_dot(node as DotHopDot)

## ready #####################################################################

func _ready() -> void:
	super._ready()

	var dots := get_tree().get_nodes_in_group("dot")
	for dot in dots:
		add_follow_dot(dot as DotHopDot)

func add_follow_dot(dot: DotHopDot) -> void:
	append_follow_targets(dot)

func drop_follow_dot(dot: DotHopDot) -> void:
	erase_follow_targets(dot)
