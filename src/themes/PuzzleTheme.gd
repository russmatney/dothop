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

func get_player_icon() -> Texture2D:
	return get_resource("player_icon_texture")

func get_dot_icon() -> Texture2D:
	return get_resource("dot_icon_texture")

func get_dotted_icon() -> Texture2D:
	return get_resource("dotted_icon_texture")

func get_goal_icon() -> Texture2D:
	return get_resource("goal_icon_texture")

func get_music_tracks() -> Array[AudioStream]:
	var tracks: Array[AudioStream] = []
	for t: String in get_theme_data().music_tracks:
		if ResourceLoader.exists(t, "AudioStream"):
			var track: AudioStream = ResourceLoader.load(t, "AudioStream")
			tracks.append(track)
		else:
			Log.warn("theme music track does not exist!", t)
	if len(tracks) == 0:
		var bg: AudioStream = get_background_music()
		if bg:
			tracks.append(bg)
	return tracks

func get_theme_data() -> PuzzleThemeData:
	return get_resource("puzzle_theme_data")

## all properties (consumed by Log.gd) #################

func data() -> Variant:
	return {
		puzzle_scene=get_puzzle_scene(),
		name=get_display_name(),
		}

## computed ############################################

## actions ############################################

func unlock() -> void:
	set_bool("is_unlocked", true)
