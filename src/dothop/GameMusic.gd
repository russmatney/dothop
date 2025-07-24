extends PuzzleNodeExtender
class_name GameMusic

## ready #####################################################################

func _ready() -> void:
	super._ready()
	SoundManager.stop_music(1.0)

## setup puzzle node #####################################################################

func setup_puzzle_node(node: DotHopPuzzle) -> void:
	# note: do we want to support multiple puzzles at once?
	puzzle_node = node

	SoundManager.stop_music(1.0)
	# TODO add music controls and toasts
	var songs: Array[AudioStream] = puzzle_node.theme_data.get_music_tracks()
	if len(songs) > 0:
		SoundManager.play_music(songs[0], 2.0)

## on p-node exiting #####################################################################

func on_puzzle_node_exiting(_node: DotHopPuzzle) -> void:
	var playing_songs: Array = SoundManager.get_currently_playing_music()
	if len(playing_songs) == 1:
		# if only one song is playing, stop it
		# otherwise, assume the cross-fade is working
		SoundManager.stop_music(2.0)

