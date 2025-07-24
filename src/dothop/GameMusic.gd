extends Node
class_name GameMusic

## vars #####################################################################

var puzzle_node: DotHopPuzzle

## enter tree #####################################################################

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		get_tree().node_added.connect(on_node_added)

func on_node_added(node: Node) -> void:
	if node is DotHopPuzzle:
		setup_puzzle_node(node as DotHopPuzzle)

## ready #####################################################################

func _ready() -> void:
	# TODO maybe want a broader search than this
	for n: Variant in get_parent().get_children():
		if n is DotHopPuzzle:
			setup_puzzle_node(n as DotHopPuzzle)
			break

	SoundManager.stop_music(1.0)

	if puzzle_node == null:
		return

## exit tree #####################################################################

func _exit_tree() -> void:
	var playing_songs: Array = SoundManager.get_currently_playing_music()
	if len(playing_songs) == 1:
		# if only one song is playing, stop it
		# otherwise, assume the cross-fade is working
		SoundManager.stop_music(2.0)

## setup puzzle node #####################################################################

func setup_puzzle_node(node: DotHopPuzzle) -> void:
	# note: do we want gameSounds supporting multiple puzzles at once?
	# note: we'll want world- or theme- based sounds at some point
	puzzle_node = node

	SoundManager.stop_music(1.0)
	# TODO add music controls and toasts
	var songs: Array[AudioStream] = puzzle_node.theme_data.get_music_tracks()
	if len(songs) > 0:
		SoundManager.play_music(songs[0], 2.0)
