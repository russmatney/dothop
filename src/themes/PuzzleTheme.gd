@tool
extends PandoraEntity
class_name PuzzleTheme

## properties ##########################################

func get_puzzle_scene() -> PackedScene:
	return get_resource("puzzle_scene")

func get_display_name() -> String:
	return get_string("display_name")

func is_unlocked() -> bool:
	return get_bool("is_unlocked")

func get_player_scenes() -> Array[PackedScene]:
	return get_theme_data().player_scenes

func get_dot_scenes() -> Array[PackedScene]:
	return get_theme_data().dot_scenes

func get_goal_scenes() -> Array[PackedScene]:
	return get_theme_data().goal_scenes

func get_background_music() -> AudioStream:
	return get_resource("background_music")

func get_player_icon() -> Texture:
	return get_resource("player_icon_texture")

func get_dot_icon() -> Texture:
	return get_resource("dot_icon_texture")

func get_dotted_icon() -> Texture:
	return get_resource("dotted_icon_texture")

func get_goal_icon() -> Texture:
	return get_resource("goal_icon_texture")

func get_music_tracks() -> Array[AudioStream]:
	var track_strs = get_theme_data().music_tracks
	var tracks: Array[AudioStream] = []
	for t in track_strs:
		if ResourceLoader.exists(t, "AudioStream"):
			var track = ResourceLoader.load(t, "AudioStream")
			tracks.append(track)
		else:
			Log.warn("theme music track does not exist!", t)
	if len(tracks) == 0:
		var bg = get_background_music()
		if bg:
			tracks.append(bg)
	return tracks

func get_theme_data() -> PuzzleThemeData:
	return get_resource("puzzle_theme_data")

## all properties (consumed by Log.gd) #################

func data():
	return {
		puzzle_scene=get_puzzle_scene(),
		name=get_display_name(),
		is_unlocked=is_unlocked(),
		player_scenes=len(get_player_scenes()),
		dot_scenes=len(get_dot_scenes()),
		goal_scenes=len(get_goal_scenes()),
		}

## computed ############################################

## actions ############################################

func unlock():
	set_bool("is_unlocked", true)
