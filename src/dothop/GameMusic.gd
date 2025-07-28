extends Node
class_name GameMusic

## ready #####################################################################

func _ready() -> void:
	var puzzle_nodes: Array = get_tree().get_nodes_in_group(DHData.puzzle_group)
	for pnode: DotHopPuzzle in puzzle_nodes:
		setup_puzzle_node(pnode)

	Events.puzzle_node.ready.connect(func(evt: Events.Evt) -> void:
		setup_puzzle_node(evt.puzzle_node))

	Events.puzzle_node.exiting.connect(func(evt: Events.Evt) -> void:
		on_puzzle_node_exiting(evt.puzzle_node))

	SoundManager.stop_music(1.0)

## setup puzzle node #####################################################################

func setup_puzzle_node(puzzle_node: DotHopPuzzle) -> void:
	if puzzle_node.theme_data:
		SoundManager.stop_music(1.0)
		# TODO add music controls and toasts
		var songs: Array[AudioStream] = puzzle_node.theme_data.get_music_tracks()
		if len(songs) > 0:
			SoundManager.play_music(songs[0], 2.0)

## on p-node exiting #####################################################################

func on_puzzle_node_exiting(puzzle_node: DotHopPuzzle) -> void:
	# TODO consider stopping only if this node is the one that started it
	if puzzle_node.theme_data:
		var playing_songs: Array = SoundManager.get_currently_playing_music()
		if len(playing_songs) == 1:
			# if only one song is playing, stop it
			# otherwise, assume the cross-fade is working
			SoundManager.stop_music(2.0)
