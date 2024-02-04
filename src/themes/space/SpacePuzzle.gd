@tool
extends DotHopPuzzle

var exit_t = 0.4
func animate_exit():
	state.players.map(func(p): p.node.animate_exit(exit_t))
	all_cell_nodes().map(func(node): node.animate_exit(exit_t))

	# return blocking signal until animations finish
	return get_tree().create_timer(exit_t).timeout
