@tool
extends Resource
class_name PuzzleThemeData

@export var display_name: String

@export var puzzle_scene: PackedScene
@export var player_scenes: Array[PackedScene]
@export var dot_scenes: Array[PackedScene]
@export var goal_scenes: Array[PackedScene]

@export var player_icon: Texture2D
@export var dot_icon: Texture2D
@export var dotted_icon: Texture2D
@export var goal_icon: Texture2D

@export var square_size: int = 32

# TODO assign AudioStreams directly?
@export var music_tracks: Array[String]

## to_pretty ##############################

func to_pretty() -> Dictionary:
	return {
		puzzle_scene=puzzle_scene,
		name=display_name,
		player_scenes=len(player_scenes),
		dot_scenes=len(dot_scenes),
		goal_scenes=len(goal_scenes),
		}

## get_music_tracks ##############################

# should we do this in the music-tracks getter?
func get_music_tracks() -> Array[AudioStream]:
	var tracks: Array[AudioStream] = []
	for t: String in music_tracks:
		if ResourceLoader.exists(t, "AudioStream"):
			var track: AudioStream = ResourceLoader.load(t, "AudioStream")
			tracks.append(track)
		else:
			Log.warn("theme music track does not exist!", t)
	# TODO restore a fallback
	# if len(tracks) == 0:
	# 	var bg = get_background_music()
	# 	if bg:
	# 		tracks.append(bg)
	return tracks

## getters ##############################

func random_player_scene() -> PackedScene:
	if len(player_scenes) > 0:
		return U.rand_of(player_scenes)
	return null

func random_dot_scene() -> PackedScene:
	if len(dot_scenes) > 0:
		return U.rand_of(dot_scenes)
	return null

func random_dotted_scene() -> PackedScene:
	if len(dot_scenes) > 0:
		return U.rand_of(dot_scenes)
	return null

func random_goal_scene() -> PackedScene:
	if len(goal_scenes) > 0:
		return U.rand_of(goal_scenes)
	return null

## static ##############################

static func get_player_scene(th: PuzzleThemeData) -> PackedScene:
	var sc: Variant = th.random_player_scene() if th else null
	if sc:
		return sc
	else:
		return load("res://src/themes/DotHopPlayer.tscn")

static func get_dot_scene(th: PuzzleThemeData) -> PackedScene:
	var sc: Variant = th.random_dot_scene() if th else null
	if sc:
		return sc
	else:
		return load("res://src/themes/DotHopDot.tscn")

static func get_dotted_scene(th: PuzzleThemeData) -> PackedScene:
	var sc: Variant = th.random_dotted_scene() if th else null
	if sc:
		return sc
	else:
		return load("res://src/themes/DotHopDot.tscn")

static func get_goal_scene(th: PuzzleThemeData) -> PackedScene:
	var sc: Variant = th.random_goal_scene() if th else null
	if sc:
		return sc
	else:
		return load("res://src/themes/DotHopDot.tscn")
